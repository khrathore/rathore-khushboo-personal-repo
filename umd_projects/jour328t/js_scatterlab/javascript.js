var ctx = document.getElementById('myChart').getContext('2d');
      var myChart = new Chart(ctx, {
          type: 'scatter',
          data: {
            datasets: [{ 
                data: [
                  {x: 71.5, y: 3.678},
                ],
                label: "China",
                borderColor: "#9E0142",
                backgroundColor: "rgb(158, 1, 66, 0.5)",
                borderWidth:1.5,
                pointRadius: 5,
              }, { 
                data: [
                  {x: 61.1, y: 2.548},
                ],
                label: "India",
                borderColor: "#D53E4F",
                backgroundColor: "rgb(213, 62, 79, 0.5)",
                borderWidth:1.5,
                pointRadius: 5,
              }, { 
                data: [
                {x: 77.1, y: 45.986},
                ],
                label: "United States",
                borderColor: "#F46D43",
                backgroundColor:"rgb(244, 109, 67, 0.5)",
                borderWidth:1.5,
                pointRadius: 5,
              }, { 
                data: [
                {x: 68.3, y: 5.878},
                ],
                label: "Indonesia",
                borderColor: "#FDAE61",
                backgroundColor:"rgb(253, 174, 97, 0.5)",
                borderWidth:1.5,
                pointRadius: 5,
              }, { 
                data: [
                {x: 71.9, y: 11.461},
                ],
                label: "Brazil",
                borderColor: "#E6F598",
                backgroundColor:"rgb(230, 245, 152, 0.5)",
                borderWidth:1.5,
                pointRadius: 5,
              }, { 
                data: [
                {x: 65.4, y: 13.173},
                ],
                label: "Russia",
                borderColor: "#ABDDA4",
                backgroundColor:"rgb(171, 221, 164, 0.5)",
                borderWidth:1.5,
                pointRadius: 5,
              }, { 
                data: [
                {x: 62.6, y: 3.366},
                ],
                label: "Pakistan",
                borderColor: "#66C2A5",
                backgroundColor:"rgb(102, 194, 165, 0.5)",
                borderWidth:1.5,
                pointRadius: 5,
              }, { 
                data: [
                {x: 65.8, y: 1.632},
                ],
                label: "Bangladesh",
                borderColor: "#3288BD",
                backgroundColor:"rgb(50, 136, 189, 0.5)",
                borderWidth:1.5,
                pointRadius: 5,
              }, { 
                data: [
                {x: 81.1, y: 32.193},
                ],
                label: "Japan",
                borderColor: "#5E4FA2",
                backgroundColor:"rgb(94, 79, 162, 0.5)",
                borderWidth:1.5,
                pointRadius: 5,
              }
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
                title: {
                  display: true,
                  text: 'Gross Domestic Product (in thousands)'
                }
              },
              x: {
                  title: {
                      display: true,
                      text: 'Current Life Expectancy'
                  }
              }
            }
          }
        });