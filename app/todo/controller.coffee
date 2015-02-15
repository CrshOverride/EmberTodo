`import Ember from 'ember'`

TodoController = Ember.ObjectController.extend
  actions:
    delete: ->
      todo = @get('model')
      todo.deleteRecord()
      todo.save()

`export default TodoController`
