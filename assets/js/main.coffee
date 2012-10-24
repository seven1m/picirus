#= require lib/vendor/bootstrap
#= require lib/vendor/underscore
#= require lib/vendor/backbone
#= require lib/vendor/d3.v2
#= require lib/vendor/nv.d3
#= require lib/vendor/stream_layers
#= require lib/sync
#= require app

Backbone.socket = io.connect()

$ ->

  exampleData = ->
    stream_layers(3,10+Math.random()*100,.1).map (data, i) ->
      key: 'Stream' + i
      values: data

  nv.addGraph ->
    chart = nv.models.multiBarChart()

    chart.xAxis
        .tickFormat(d3.format(',f'))

    chart.yAxis
        .tickFormat(d3.format(',.1f'))

    d3.select('#chart1 svg')
        .datum(exampleData())
      .transition().duration(500).call(chart)

    nv.utils.windowResize(chart.update)

    chart

  exampleData2 = ->
    [
      {
        key: "Cumulative Return",
        values: [
          { 
            "label" : "CDS / Options" ,
            "value" : 29.765957771107
          } , 
          { 
            "label" : "Cash" , 
            "value" : 0
          } , 
          { 
            "label" : "Corporate Bonds" , 
            "value" : 32.807804682612
          } , 
          { 
            "label" : "Equity" , 
            "value" : 196.45946739256
          } , 
          { 
            "label" : "Index Futures" ,
            "value" : 0.19434030906893
          } , 
          { 
            "label" : "Options" , 
            "value" : 98.079782601442
          } , 
          { 
            "label" : "Preferred" , 
            "value" : 13.925743130903
          } , 
          { 
            "label" : "Not Available" , 
            "value" : 5.1387322875705
          }
        ]
      }
    ]

  nv.addGraph ->
    chart = nv.models.pieChart()
      .x((d) -> d.label)
      .y((d) -> d.value)
      .showLabels(true)
      .labelThreshold(.05)
      .donut(true)

    d3.select("#chart2 svg")
        .datum(exampleData2())
      .transition().duration(1200)
        .call(chart);

    chart
