# base 'plugins' for mongoose models

_ = require('underscore')

exports.timestamps = (schema, options) ->

  schema.pre 'save', (next) ->
    if !@created
      @created = @updated = new Date()
    else
      @updated = new Date()
    next()

exports.sync = (schema, options={}) ->

  options[k] ?= false for k in ['read', 'create', 'update', 'delete']
  options[k] ?= _.identity for k in ['beforeRead', 'afterRead', 'beforeCreate', 'afterCreate', 'beforeUpdate', 'afterUpdate', 'afterConnect']

  updateData = (model, data, session) ->
    model.session_id = session._id
    model.user_id = session.user_id
    for key, val of data when not options.keys or key in options.keys
      model[key] = val

  schema.statics.sync = (socket) ->
    name = @modelName.toLowerCase()

    if options.read
      socket.on "sync.#{name}.read", (data, cb) =>
        socket.get 'session', (err, session) =>
          if err then throw err
          options.beforeRead(data, session, socket)
          this.find data, (err, models) ->
            options.afterRead(models, session, socket)
            cb err, models

    if options.create
      socket.on "sync.#{name}.create", (data, cb) =>
        socket.get 'session', (err, session) =>
          if err then throw err
          options.beforeCreate(data, session, socket)
          model = new this
          updateData model, data, session
          model.save (err) ->
            options.afterCreate(model, session, socket)
            cb err, model

    if options.update
      socket.on "sync.#{name}.update", (data, cb) =>
        socket.get 'session', (err, session) =>
          if err then throw err
          options.beforeUpdate(data, session, socket)
          this.findOne _id: data._id, (err, model) ->
            if err then throw err
            updateData model, data, session
            model.save (err) ->
              options.afterUpdate(model, session, socket)
              cb err, model

    options.afterConnect(socket)
