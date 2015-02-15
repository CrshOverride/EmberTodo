`import Ember from 'ember'`

TodosController = Ember.ArrayController.extend
  actions:
    add: ->
      text = @get('new_todo')
      new_todo = @get('store').createRecord('todo', id: text, text: text)
      new_todo.save()
      @set('new_todo','')

`export default TodosController`
