var ctx = document.getElementById('myChart').getContext('2d');
var myChart = new Chart(ctx, {
    type: 'bar',
    data: {
        labels: ['Two Books', 'Three Books', 'Four Books'],
        datasets: [{
            label: 'Number of Authors',
            data: [15, 3, 1],
            backgroundColor: [
                '#A03472'
            ]
        }
    ]
    },
    options: {
        responsive: true,
        scales: {
            y: {
                beginAtZero: true
            }
        },
    },
});