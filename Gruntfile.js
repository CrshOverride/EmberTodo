module.exports = function(grunt) {
  require('load-grunt-tasks')(grunt);

  grunt.initConfig({
    shell: {
      options: {
        stdout: true,
        stdin: false
      },
      target: {
        command: 'ember build'
      }
    }
  });

  grunt.registerTask('default', ['shell'])
}
