#sparql_manager.rb
require 'rubygems'
require 'json'
require 'open-uri'
require 'cgi'
require './model/triplet.rb'

# @author Daniel Machado Fernández
# @version 1.0
#
# Manage all SPARQL queries
class SPARQLManager
	
	# Retrieves the ten diseases which have got more cases
	#
	# @return [Array] filled by Triplets
	def top_ten_diseases
	
		endpoint = "http://156.35.98.14:3031/datos/query"
		query = <<-EOS
		PREFIX ns3: <http://dbpedia.org/datatype/>
		PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
		PREFIX dbpedia: <http://dbpedia.org/resource/>
		PREFIX dbpprop: <http://dbpedia.org/property/>
		PREFIX uniprop: <http://uniovi.es/miw/property/> 
		SELECT ?pais ?enfermedad ?casos WHERE{
		   ?x uniprop:country ?pais .
		   ?x uniprop:disease ?enfermedad .
		   ?x uniprop:casos ?casos . }
		ORDER BY DESC(?casos)
		LIMIT 10
		EOS
		
		res = JSON.pretty_generate(query(query, endpoint))
		res = JSON.parse(res)
		res = res["results"]["bindings"]
		triplets = Array.new
		
		res.each do |line|
			triplet = Triplet.new
			x = line["pais"]["value"]
			p = line["enfermedad"]["value"]
			o = line["casos"]["value"]
			
			x = x.split('/')[4]
			p = p.split('/')[4]

			triplet.x = x
			triplet.p = p
			triplet.o = o

			triplets << triplet
		end
		
		triplets
		
	end
	
	# Relation between power consumption and lephrosy in countrys which power consumption is higher than 1000
	#
	# @return [Array] filled by Triplets
	def electric_disease_relation

		endpoint = "http://156.35.98.14:3031/datos/query"
		query = <<-EOS
		PREFIX ns3: <http://dbpedia.org/datatype/>
		PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
		PREFIX dbpedia: <http://dbpedia.org/resource/>
		PREFIX dbpprop: <http://dbpedia.org/property/>
		PREFIX uniprop: <http://uniovi.es/miw/property/>
		SELECT ?pais ?casos ?consumo WHERE{
			?x uniprop:country ?pais .
			?x uniprop:disease dbpedia:Leprosy .
			?x uniprop:casos ?casos .
			?y uniprop:epc ?consumo .
			?y uniprop:country ?pais .
			FILTER(?consumo>1000)
		}
		EOS
		
		res = JSON.pretty_generate(query(query, endpoint))
		res = JSON.parse(res)
		res = res["results"]["bindings"]
		triplets = Array.new
		
		res.each do |line|
			triplet = Triplet.new
			x = line["pais"]["value"]
			x = x.split('/')[4]
			triplet.x = x
			triplet.p = line["casos"]["value"]
			triplet.o = line["consumo"]["value"]
			triplets << triplet
		end
		
		triplets
	
	end
	
	# Number of infected people vs census people by countries with low number of people
	#
	# @return [Array] filled by Triplets
	def diseases_census_ratio
	
		endpoint = "http://156.35.98.14:3031/datos/query"
		query = <<-EOS
		PREFIX ns3: <http://dbpedia.org/datatype/>
		PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
		PREFIX dbpedia: <http://dbpedia.org/resource/>
		PREFIX dbpprop: <http://dbpedia.org/property/>
		PREFIX uniprop: <http://uniovi.es/miw/property/>
		SELECT ?pais ?habitantes (SUM(?casos) AS ?numcasos) WHERE{
			?x uniprop:country ?pais .
			?x uniprop:casos ?casos .
			?pais dbpprop:populationCensus ?habitantes .
			FILTER(?habitantes>100000 || ?habitantes<1000000)
			FILTER (?casos > 0)
		}
		GROUP BY ?pais ?habitantes
		LIMIT 50
		EOS
		
		res = JSON.pretty_generate(query(query, endpoint))
		res = JSON.parse(res)
		res = res["results"]["bindings"]
		triplets = Array.new
		
		res.each do |line|
			triplet = Triplet.new
			x = line["pais"]["value"]
			x = x.split('/')[4]
			triplet.x = x
			p = line["habitantes"]["value"]
			o = line["numcasos"]["value"]
			triplet.o = p.to_f/o.to_f

			triplets << triplet
		end
		
		triplets
	end
	
	# Number of infected people vs health facilities in countries wich have got less than 50%
	#
	# @return [Array] filled by Triplets
	def afected_facilities_ratio
	
		endpoint = "http://156.35.98.14:3031/datos/query"
		query = <<-EOS
		PREFIX ns3: <http://dbpedia.org/datatype/>
		PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
		PREFIX dbpedia: <http://dbpedia.org/resource/>
		PREFIX dbpprop: <http://dbpedia.org/property/>
		PREFIX uniprop: <http://uniovi.es/miw/property/>
		SELECT ?pais (SUM(?casos) AS ?numcasos) ?facilidades WHERE{
			?x uniprop:country ?pais .
			?x uniprop:casos ?casos .
			?y uniprop:isf ?facilidades .
			?y uniprop:country ?pais .
			FILTER (?facilidades < 50)
			FILTER (?casos > 0)
		}
		GROUP BY ?pais ?facilidades
		ORDER BY DESC (?numcasos)
		EOS
		
		res = JSON.pretty_generate(query(query, endpoint))
		res = JSON.parse(res)
		res = res["results"]["bindings"]
		triplets = Array.new
		
		res.each do |line|
			triplet = Triplet.new
			x = line["pais"]["value"]
			x = x.split('/')[4]
			triplet.x = x
			triplet.p = line["numcasos"]["value"]
			triplet.o = line["facilidades"]["value"]
			triplets << triplet
		end
		
		triplets
	end
	
	# Returns a JSON object with the results of a SPARQL query
	#
	# @return [String] with the generated JSON
	def query(query, endpoint, accept = "application/json")
		json = open("#{endpoint}?query=#{CGI.escape(query)}&output=json&stylesheet=%2Fxml-to-html.xsl&force-accept=text%2Fplain").read
		JSON.parse(json)
	end
	
end

