var ctx = document.getElementById('myChart').getContext('2d');
var myChart = new Chart(ctx, {
    type: 'line',

    data: {
        labels: ['1996', '1997', '1998', '1999', '2000', '2001', '2002', '2003', '2004', '2005', '2006', 
          '2007', '2008', '2009', '2010', '2011', '2012', '2013', '2014', '2015', '2016', '2017'],
        datasets: [{
            label: 'Female Authors',
            data: [2, 4, 4, 4, 2, 2, 3, 4, 2, 3, 4, 2, 4, 6, 6, 4, 3, 6, 6, 7, 4, 6],
            fill: false,
            borderColor: '#D7263D',
            backgroundColor: '#D7263D',
            tension: 0.2},
        {
            label: 'Male Authors',
            data: [6, 7, 7, 7, 8, 7, 4, 5, 8, 7, 6, 8, 6, 4, 4, 6, 7, 4, 4, 3, 6, 4],
            fill: false,
            borderColor: '#519E8A',
            backgroundColor: '#519E8A',
            tension: 0.2}
        ]
    },
    options: {
      plugins: {
          legend: {
              display: true,
              position: 'bottom',
              labels: {
                  color: '#000000',
                  boxWidth: 10,
                  usePointStyle: false,
                  boxHeight: 10,
              }
          },
      },
      scales: {
        y: {
          begintAtZero: true,
          title: {
            display: true,
            text: 'Number of Authors Listed',
          },
          
        },
        x: {
            title: {
                display: true,
                text: 'Year'
            }
        }
      }
    }
  });