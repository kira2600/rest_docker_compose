require "sinatra/base"
require 'yaml'
require 'json'
#require 'docker'
#require 'docker-compose'

module YamlFile
  class Write
    include YAML
    def write_file(values)
#p values
      File.open('./docker-compose.yml', 'w') do |f|
        f.write(values.to_yaml)
        f.close
      end
    end
  end
end

module MyDocker

  class Manage

    def up_compose
    system"docker-compose up -d"
    end

    def docker_version
       result =  `docker -v`
      return result
    end
    
    def down_compose
      system "docker-compose down"
    end
  end
end


module CREATE

  class Compose

    def compose_template
      template = {'version'=>'2.1', 'services'=>{'test_centos'=>{'build'=>'./docker_centos', 'container_name'=>'andy_centos_1', 'networks'=>{'network_andy'=>{'ipv4_address'=>'10.10.10.13'}}}}, 'networks'=>{'network_andy'=>{'driver'=>'bridge', 'ipam'=>{'driver'=>'default', 'config'=>[{'subnet'=>'10.10.10.0/24', 'gateway'=>'10.10.10.1'}]}}}}
      send_data = YamlFile::Write.new
      send_data.write_file(template)
    end

  end

end


module VALIDATION

  class Json_validation
  
    def valid_json(recieved_params)
      begin
        recieved_params_json = JSON.parse(recieved_params)
        return recieved_params_json
        rescue JSON::ParserError => e
        return "ABORTED!It is not a JSON format"
        exit(false)
            
      end
    end 
  end

end

module API 

   class Requests < Sinatra::Base

     public
  
  set :root, File.dirname(__FILE__)

#create compose file
        post '/api/compose/config/create/' do

          recieved_params = request.body.read
          
          if recieved_params == 'create'
          send_data = CREATE::Compose.new
          send_data.compose_template
          else
          p "err create"
          end

        end

#change compose file
       post '/api/compose/config/change/' do
  
         recieved_params = request.body.read
         
         validation_data = VALIDATION::Json_validation.new
         validation_data.valid_json(recieved_params)
         recieved_params_json = validation_data.valid_json(recieved_params)

        template_change = YAML.load(File.read("./docker-compose.yml"))

#p template_change

           recieved_params_json.each do |key, value|

              @param_key = key.to_s
              @param_val = value

           end 

           @param_key = "#{@param_key}"
           @param_val = "#{@param_val}"
#p @param_key
#p @param_val
           #recursive find hashes
           def update_links(template_change)
             template_change.each do |k, v|
               if k == @param_key && v.is_a?(String)
                 # update here
                 v.replace @param_val
               elsif v.is_a?(Hash)
                 update_links v
               elsif v.is_a?(Array)
                 v.flatten.each { |x| update_links(x) if x.is_a?(Hash) }
               end
             end
            template_change
           end

           update_links(template_change)
          
          send_data = YamlFile::Write.new
          send_data.write_file(template_change)

        end
  
#view compose file
        get '/api/compose/config/view/' do
           send_file './docker-compose.yml'
        end

#remove compose file
        delete '/api/compose/config/remove/' do
           FileUtils.rm('./docker-compose.yml')
        end

#get docker version
      get '/api/docker/version/' do

         action = MyDocker::Manage.new
         action.docker_version
      end 

#compose up
      post '/api/compose/up/' do
        
        recieved_params = request.body.read 
        if recieved_params == 'up'
         action = MyDocker::Manage.new
         action.up_compose
        end
      end 

#compose down
      post '/api/compose/down/' do
        
        recieved_params = request.body.read 
        if recieved_params == 'down'
         action = MyDocker::Manage.new
         action.down_compose
        end
      end 
   end

end


