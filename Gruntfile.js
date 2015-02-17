module.exports = function(grunt) {
  require('load-grunt-tasks')(grunt);

  grunt.initConfig({
    shell: {
      options: {
        stdout: true,
        stdin: false
      },
      target: {
        command: 'ember build -prod'
      }
    }
  });

  grunt.registerTask('default', ['shell'])
}
