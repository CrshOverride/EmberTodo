`import Ember from 'ember'`
`import AuthenticatedRouteMixin from 'simple-auth/mixins/authenticated-route-mixin'`

TodosRoute = Ember.Route.extend AuthenticatedRouteMixin,
  model: ->
    @.get('store').findAll('todo')

`export default TodosRoute`
