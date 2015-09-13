require 'sqlite3'

module Palmade::Tapsilog::Adapters
  class SqliteAdapter < BaseAdapter

    def initialize(config)
      @config = config
      @database_name = "#{config[:sqlite_database_name]}"
      @database_path = "#{config[:sqlite_database_path]}/#{@database_name}"
      
      @database = SQLite3::Database.new @database_path
      
      @database.execute "
  CREATE TABLE IF NOT EXISTS tapsilog (
    service varchar(30),
    message text,
    tags varchar(30)
  );
"
    end

    def write(log_message)
      service = log_message[1].to_s
      tags = log_message[5]
      message = log_message[4]
      
			@database.execute("INSERT INTO tapsilog (service, message, tags) 
            VALUES (?, ?, ?)", [service, message, tags])    	
    end
    
    def rotate_sqlite_database
			today = "#{@database_path}#{@database_name}.sqlite"

      yesterday  = Date.today.prev_day.strftime("%Y%m%d")
      
      yesterday_file = "#{database_path}/#{database_name}/#{yesterday}.sqlite"
      
      File.rename(today, yesterday_file)
      
      @database = SQLite3::Database.new @database_path
    end

  end
end
