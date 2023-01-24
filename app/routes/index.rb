module MongoAdmin
  class App < Sinatra::Base

    get '/' do
      info = settings.db.client.command(serverStatus: 1)
      admin_client = settings.db.client.use('admin')
      @operations = admin_client.command(currentOp: 1).documents.first
      if @operations
          @operations = @operations['inprog'].reject! do |op|
              op.fetch('secs_running', 0) < 3 || op['ns'] =~ /^local/
           end
      end

      @info = info.documents.first
      slim :index
    end

    delete '/ops/:operation_id' do
      admin_client = settings.db.client.use('admin')
      op_id = params['operation_id'].to_i
      admin_client.command(killOp: 1, op: op_id).first

      flash[:info] = I18n.t('op_id_killed', op_id: op_id)
      redirect "/"
    end


    get '/error' do
      slim :error, layout: false
    end

  end
end

