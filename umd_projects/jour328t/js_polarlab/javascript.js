var ctx = document.getElementById('myChart').getContext('2d');
      var myChart = new Chart(ctx, {
          type: 'radar',
          data: {
            labels: [
              'Education',
              'Caring for Household Members',
              'Housework',
              'Shopping',
              'Unpaid Work & Volunteering',
              'Eating & Drinking',
              'Personal Care',
              'Sports',
              'Attending Events',
              'Seeing Friends',
              'TV and Radio',
              'Other Leisure Activities'
            ],
            datasets: [{
              label: 'Chinese Time Use',
              data: [25,	23,	103,	20,	33,	100,	52,	23,	2,	23,	127,	53],
              fill: true,
              backgroundColor: 'rgba(238, 28, 37, 0.2)',
              borderColor: 'rgb(238, 28, 37)',
              pointBackgroundColor: 'rgb(238, 28, 37)',
              pointBorderColor: '#fff',
              pointHoverBackgroundColor: '#fff',
              pointHoverBorderColor: 'rgb(238, 28, 37)'
            },
            {
              label: 'American Time Use',
              data: [31,	31,	100,	22,	65, 63,	57,	18,	8,	44,	148,	73],
              fill: true,
              backgroundColor: 'rgba(10, 49, 97, 0.2)',
              borderColor: 'rgb(10, 49, 97)',
              pointBackgroundColor: 'rgb(10, 49, 97)',
              pointBorderColor: '#fff',
              pointHoverBackgroundColor: '#fff',
              pointHoverBorderColor: 'rgb(10, 49, 97)'
            }]
          },
          options: {
            responsive: true,
            plugins: {
              legend: {
                display: true,
                position: 'top',
                labels: {
                    color: '#000000',
                    boxWidth: 10,
                    usePointStyle: false,
                    boxHeight: 10,
                }
              },
            },
            elements: {
              line: {
                borderWidth: 3
              }
            },
          }
        });