module MongoAdmin
  class App < Sinatra::Base

    get '/' do
      info = @db.client.command(serverStatus: 1)
      
      admin_client = @db.client.use('admin')
      @operations = admin_client.command(currentOp: 1).documents.first
      if @operations
          @operations = @operations['inprog'].reject! do |op|
              op.fetch('secs_running', 0) < 5 || op['ns'] =~ /^local/
           end
      end
      
      @info = info.documents.first
      slim :index
    end

    delete '/ops/:operation_id' do
      admin_client = @db.client.use('admin')
      op_id = params['operation_id']
      admin_client.command(killOp: 456, op: op_id).find().first

      flash[:info] = I18n.t('op_id_killed', op_id: op_id)
      redirect "/"
    end


    get '/error' do
      slim :error, layout: false
    end

  end
end

