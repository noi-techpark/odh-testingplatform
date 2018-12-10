$(document).ready( function () {
	
   $.ajax( {
      url: "list",
      type: "GET",
      dataType: "xml",
      error: function(xhr,status,error) {
         console.log(xhr);
         alert("Error: " + status);
      },
      success: function(xml) {
         var dataSet = [];
         var testTot = 0;
         var testOk = 0;
         $.each(xml.documentElement.children, function( index, repository ) {

            var dataSetTestcases = [];
            for (let i = 0; i < repository.children.length; i++)
            {
               let testCases = repository.children[i];

               for (let i = 0; i < testCases.children.length; i++)
               {
                  let testCase = testCases.children[i];
                  var dataSetTests = [];
                    
                  dataSetTestcases[dataSetTestcases.length] = [
                     dataSetTests,
                     [testCase.attributes['testCase'].value, testCases.attributes['testfile_path']? testCases.attributes['testfile_path'].value: ""],
                     testCase.attributes['status'].value,
                     testCase.attributes['timeStamp'].value,
                     testCase.children.length,
                     testCase
                  ]
                  for (let i = 0; i < testCase.children.length; i++)
                  {
                     let test = testCase.children[i];
                     dataSetTests[dataSetTests.length] = [
                        test.attributes['name'].value,
                        test.attributes['httpStatus'].value,
                        test.attributes['status'].value,
                        test.firstElementChild? test.firstElementChild.textContent: ""
                     ];
                  }
               }
            }
              
            dataSet[dataSet.length] = [
               dataSetTestcases,
               repository.attributes['id'].value,
               repository.attributes['name'].value,
               repository.attributes['timestamp'].value,
               repository.attributes['tot'].value,
               repository.attributes['tot'].value - repository.attributes['ok'].value
            ];
            
            if(parseInt(repository.attributes['ok'].value)) {
               testOk += parseInt(repository.attributes['ok'].value);
            }
            if(parseInt(repository.attributes['tot'].value)) {
               testTot += parseInt(repository.attributes['tot'].value);
            }


         });
         $("#test-failed").text(testTot - testOk);
         $("#test-tot").text(testTot);
         if(testOk == 0) {
        	 $(".status-button-svg").addClass("ok");
         } else if(testOk < testTot) {
        	 $(".status-button-svg").addClass("failed");
         }
         var table = $('#table_id').DataTable( {
            data: dataSet,
            columns: [
               {
                  className:      'details-control test-suite',
                  orderable:      false,
                  data:           null,
                  defaultContent: '',
                  createdCell: function (td, cellData, rowData, row, col) {
                     if (rowData[0].length == 0) {
                        $(td).addClass('empty');
                     }
                  }
               },
               { title: "#" },
               {
            	   title: "repository name",
                   createdCell: function (td, cellData, rowData, row, col) {
                	   $(td).empty();
                       $(td).append($('<a href="' + cellData + '">' + cellData + '</a>'));
                    }
               },
               { title: "timestamp" },
               {
                  title: "tot",
                  createdCell: function (td, cellData, rowData, row, col) {
                     if(cellData == 0) {
                        $(td).addClass('no-tests');
                     }
                  }
               },
               {
                  title: "failed",
                  createdCell: function (td, cellData, rowData, row, col) {
                     if(cellData != 0) {
                        $(td).addClass('some-test-failed');
                     }
                  }
               }
            ],
            order: [[4, 'desc']],
            pageResize: true
         } );
         table.order([5, 'desc']).draw();
         console.log(table.order())
         $('#table_id tbody').on('click', 'td.details-control.test-suite', function () {
            var tr = $(this).closest('tr');
            var row = table.row( tr );
            var testSuiteIndex = row.index();
        
            if ( row.child.isShown() ) {
               row.child.hide();
               tr.removeClass('shown');
            } else {
               row.child( '<table id="test_suite_table_' + testSuiteIndex + '" class="table table-striped table-bordered" style="width: 100%"></table>' ).show();
               tr.addClass('shown');
                  
               var dataSetTestSuite = dataSet[testSuiteIndex][0];
                   
               var tableTestSuite = $('#test_suite_table_' + testSuiteIndex).DataTable( {
                  data: dataSetTestSuite,
                  columns: [
                     {
                        className:      'details-control test',
                        orderable:      false,
                        data:           null,
                        defaultContent: '',
                        createdCell: function (td, cellData, rowData, row, col) {
                           if (rowData[0].length == 0) {
                              $(td).addClass('empty');
                           }
                        }
                     },
                     {
                    	 title: "test suite name",
                         createdCell: function (td, cellData, rowData, row, col) {
                      	   $(td).empty();
                             $(td).append($('<a href="' + dataSet[testSuiteIndex][2] + '/blob/master/' + cellData[1] + '">' + cellData[0] + '</a>'));
                          }
                     },
                     { title: "timestamp" },
                     { title: "time" },
                     { title: "# of tests" },
                     {
                         className:      '',
                         orderable:      false,
                         data:           null,
                         defaultContent: '',
                         createdCell: function (td, cellData, rowData, row, col) {
                            let a = $('<a>Raw</a>');
                            a.attr('href', 'data:text/octet-stream;base64,' + btoa(new XMLSerializer().serializeToString(rowData[col])));
                            a.attr('target', 'xml')
                            $(td).append(a);
                         }
                      }
                  ],
                  order: [[1, 'asc']],
                  paging: false,
                  searching: false,
                  info: false,
                  pageResize: true
               } );
               $('#test_suite_table_' + testSuiteIndex + ' tbody').on('click', 'td.details-control.test', function () {
                  var tr = $(this).closest('tr');
                  var row = tableTestSuite.row( tr );
               
                  if ( row.child.isShown() ) {
                     row.child.hide();
                     tr.removeClass('shown');
                  } else {
                     let repository = xml.documentElement.children[row.index()];
                     row.child( '<table id="test_suite_tests_table_' + testSuiteIndex + '_' + row.index() +'" class="table table-striped table-bordered" style="width: 100%"></table>' ).show();
                     tr.addClass('shown');
                          
                     $('#test_suite_tests_table_' + testSuiteIndex + '_' + row.index()).DataTable( {
                        data: dataSetTestSuite[row.index()][0],
                        columns: [
                           {
                              title: "test name",
                              className: "testname"
                           },
                           {
                              title: "HTTP status",
                              className: "status"
                           },
                           { 
                              title: "test status",
                              createdCell: function (td, cellData, rowData, row, col) {
                                 $(td).addClass('status-' + cellData);
                              },
                              className: "status"
                           },
                           { 
                              title: "message",
                              className: "message"
                           }
                        ],
                        paging: false,
                        searching: false,
                        info: false,
                        pageResize: true
                     } );
                  }
               });
            }
         } );
      }
   });
   
   // chart
   
   $.ajax( {
	      url: "chart",
	      type: "GET",
	      dataType: "json",
	      error: function(xhr,status,error) {
	         console.log(xhr);
	         alert("Error: " + status);
	      },
	      success: function(json) {
	    	  console.log(json)
	    	  let data_tot = ['tot'];
	    	  let data_ok = ['ok']
	    	  let cats = [];
	    	  for (let i = 0; i < json.length; i++)
	          {
	    		  let row = json[i]
	    		  console.log(row)
	    		  cats.push(row.day)
	    		  data_tot.push(row.tot)
	    		  data_ok.push(row.ok)
	          }
	    	  var chart = c3.generate({
	    		   bindto: '#chart',
	    		   data: {
	    		        columns: [
	    		            data_tot,
	    		            data_ok
	    		        ]
	    		   },
	    		   axis: {
	    			    x: {
	    			        type: 'category',
	    			        categories: cats,
	    		            tick: {
	    		                rotate: 90,
	    		                multiline: false
	    		            },
	    			    }
	    		   }
	    		});
	      }
   })

   
   

});