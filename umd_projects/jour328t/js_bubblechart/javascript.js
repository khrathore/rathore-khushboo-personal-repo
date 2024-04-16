var ctx = document.getElementById('myChart').getContext('2d');
      var myChart = new Chart(ctx, {
        type: 'bubble',
        data: {
          datasets: [{
            data: [
              { x: 10259, y: 264, r: 3.7, label: "Autumn" },
              { x: 27086, y: 240, r: 3.8, label: "Exit West" },
              { x: 10929, y: 496, r: 4.2, label: "Pachinko" },
              { x: 16655, y: 288, r: 3.9, label: "The Power" },
              { x: 7033, y: 285, r: 4.1, label: "Sing, Unburied, Sing" },
              { x: 147, y: 400, r: 4.1, label: "The Evolution of Beauty" },
              { x: 569, y: 1104, r: 4.6, label: "Grant" },
              { x: 254, y: 320, r: 4.3, label: "Locking Up Our Own" },
              { x: 89, y: 640, r: 4.3, label: "Prairie Fires" },
              { x: 2415, y: 336, r: 3.9, label: "Priestdaddy" },
              { x: 6788, y: 288, r: 3.6, label: "The Association of Small Bombs" },
              { x: 12646, y: 272, r: 4, label: "The North Water" },
              { x: 82601, y: 306, r: 4, label: "The Underground Railroad" },
              { x: 34421, y: 188, r: 3.6, label: "The Vegetarian" },
              { x: 4240, y: 304, r: 3.9, label: "War and Turpentine" },
              { x: 2886, y: 440, r: 4.2, label: "At the Existentialist Cafe" },
              { x: 7622, y: 464, r: 4.3, label: "Dark Money" },
              { x: 15452, y: 418, r: 4.5, label: "Evicted" },
              { x: 1520, y: 432, r: 4, label: "In the Darkroom" },
              { x: 2123, y: 288, r: 4.2, label: "The Return" },
              { x: 8242, y: 272, r: 4.1, label: "The Door" },
              { x: 7661, y: 432, r: 4.2, label: "A Manual for Cleaning Women" },
              { x: 6499, y: 249, r: 3.4, label: "Outline" },
              { x: 25137, y: 289, r: 3.8, label: "The Sellout" },
              { x: 27561, y: 480, r: 4.4, label: "The Story of the Lost Child" },
              { x: 99500, y: 152, r: 4.4, label: "Between the World and Me" },
              { x: 1311, y: 640, r: 3.8, label: "Empire of Cotton" },
              { x: 37386, y: 300, r: 3.7, label: "H is for Hawk" },
              { x: 5069, y: 473, r: 4.3, label: "The Invention of Nature" },
              { x: 4396, y: 530, r: 4.3, label: "One of Us" },
              { x: 530482, y: 531, r: 4.3, label: "All the Light We Cannot See" },
              { x: 24176, y: 179, r: 3.7, label: "Dept. of Speculation" },
              { x: 47683, y: 261, r: 3.8, label: "Euphoria" },
              { x: 7043, y: 240, r: 3.5, label: "Family Life" },
              { x: 17903, y: 288, r: 4, label: "Redeployment" },
              { x: 19551, y: 228, r: 4.1, label: "Can't We Talk about Something More Pleasant" },
              { x: 6303, y: 205, r: 3.9, label: "On Immunity" },
              { x: 299, y: 508, r: 4, label: "Penelope Fitzgerald" },
              { x: 23956, y: 319, r: 4.1, label: "The Sixth Extinction" },
              { x: 1891, y: 368, r: 4.1, label: "Thirteen Days in September" },
              { x: 131199, y: 477, r: 4.3, label: "Americanah" },
              { x: 14824, y: 383, r: 3.5, label: "The Flamethrowers" },
              { x: 456286, y: 771, r: 3.9, label: "The Goldfinch" },
              { x: 157127, y: 531, r: 3.7, label: "Life After Life" },
              { x: 2543, y: 272, r: 4, label: "Tenth of December" },
              { x: 1485, y: 304, r: 3.9, label: "The Boy in the Moon" },
              { x: 11675, y: 608, r: 4.2, label: "Malcolm X" },
              { x: 145725, y: 499, r: 4.1, label: "Thinking, Fast and Slow" },
              { x: 1690, y: 988, r: 4, label: "A World on Fire" },
              { x: 129779, y: 562, r: 3.7, label: "Freedom" },
              { x: 835, y: 528, r: 3.8, label: "The New Yorker Stories" },
              { x: 549432, y: 321, r: 4, label: "Room" },
              { x: 347, y: 576, r: 4.3, label: "Selected Stories" },
            ],        
              backgroundColor: '#3F888F'
          }]
        },
          options: {
            plugins: {
                legend: {
                    display: false,
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
                  text: 'Number of Pages'
                }
              },
              x: {
                  title: {
                      display: true,
                      text: 'Number of Ratings'
                  }
              }
            }
          }
        });