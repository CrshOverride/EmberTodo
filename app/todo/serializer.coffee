`import DS from 'ember-data'`

TodoSerializer = DS.RESTSerializer.extend
  serialize: (todo, options) ->
    json = @_super(todo, options)
    `delete json.id`
    json

  extractArray: (store, type, payload) ->
    payload = { todos: payload.map((todo) -> id: todo, text: todo) }
    @._super(store, type, payload)

`export default TodoSerializer`
