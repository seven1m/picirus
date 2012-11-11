function humanSize(bytes) {
  kb = bytes / 1024;
  mb = kb / 1024;
  gb = mb / 1024;
  if(gb >= 1.0)
    return (Math.round(gb * 10) / 10) + ' GiB';
  else if(mb >= 1.0)
    return (Math.round(mb * 10) / 10) + ' MiB';
  else if(kb >= 1.0)
    return (Math.round(kb * 10) / 10) + ' KiB';
  else
    return bytes + ' bytes';
}

$(function() {
  $.get('/stats/backups', function(data) {
    var chart = new Highcharts.Chart({
      chart: {
        renderTo: 'chart-daily',
        type: 'column'
      },
      title: {
        text: 'Daily Backup Stats'
      },
      xAxis: {
        categories: data.categories
      },
      yAxis: {
        min: 0,
        title: {
          text: 'Files'
        }
      },
      legend: {
        layout: 'vertical',
        backgroundColor: '#FFFFFF',
        align: 'left',
        verticalAlign: 'top',
        x: 100,
        y: 70,
        floating: true,
        shadow: true
      },
      tooltip: {
        formatter: function() {
          return ''+this.y;
        }
      },
      plotOptions: {
        column: {
          pointPadding: 0.2,
          borderWidth: 0
        }
      },
      series: data.series
    });
  });

  $.get('/stats/storage', function(data) {
    var chart = new Highcharts.Chart({
      chart: {
        renderTo: 'chart-storage',
        plotBackgroundColor: null,
        plotBorderWidth: null,
        plotShadow: false,
        spacingLeft: 70,
        spacingRight: 70
      },
      title: {
        text: 'Storage'
      },
      tooltip: {
        formatter: function() { return humanSize(this.y) },
        percentageDecimals: 1
      },
      plotOptions: {
        pie: {
          allowPointSelect: true,
          cursor: 'pointer',
          dataLabels: {
            enabled: true,
            color: '#000000',
            connectorColor: '#000000',
            formatter: function() {
              return this.point.name;
            }
          }
        }
      },
      series: [{
        type: 'pie',
        name: 'Space Used',
        data: data
      }]
    });
  });
});
