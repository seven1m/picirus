/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    watch: {
      files: ['**/*.coffee'],
      tasks: 'spec'
    },
    jasmine_node: {
      spec: "./spec",
      projectRoot: ".",
      extensions: "coffee",
      requirejs: false,
      forceExit: true,
      jUnit: {
        report: false,
        savePath : "./build/reports/jasmine/",
        useDotNotation: true,
        consolidate: true
      }
    }
  });

  grunt.loadNpmTasks('grunt-jasmine-node');

  grunt.registerTask('default', 'jasmine_node');

};
