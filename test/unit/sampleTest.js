







// describe('LoginCtrl', function(){
//     var scope, $httpBackend ,createController,timeout;//use these in tests

//     beforeEach(angular.mock.module('vxApp'));

//     it("should return success", function(){
//       expect(0).toBe(0);
//     });

//     it("should return success", function(){
//       expect(0).toBe(5);
//     });

//     it("should return success", function(){
//       expect(0).toBe(2);
//     });

//     beforeEach(angular.mock.inject(function($rootScope, $controller, _$httpBackend_,$timeout){
//         $httpBackend = _$httpBackend_;
//         timeout=$timeout
//         $httpBackend.when('GET', '/agents').respond([{
//                                                       _id: '1',
//                                                       mac_url: 'bsjiakmgr02.thoughtworks.com',
//                                                       mac_status: 'idle',
//                                                       ip_addr:'192.168.0.5',
//                                                       catalog: '/var/lib/cruise-agent',
//                                                       resources:['ubuntu','mysql','firefox']
//                                                     }
//                                                   ]);
//         $httpBackend.when('POST','/agents').respond(200,'');
//         $httpBackend.when('DELETE','/agents/1?resource=mysql').respond(204,'');
//         //create an empty scope
//         scope = $rootScope.$new();
//         //declare the controller and inject our empty scope
//         $controller('LoginCtrl', {$scope: scope});
//         createController = function(){
//           $controller('LoginCtrl', {$scope: {}});
//         }
//     }))




//     //mock Application to allow us to inject our own dependencies
// //     //mock the controller for the same reason and include $rootScope and $controller
// //     beforeEach(angular.mock.inject(function($rootScope, $controller, _$httpBackend_,$timeout){
// //         $httpBackend = _$httpBackend_;
// //         timeout=$timeout
// //         $httpBackend.when('GET', '/agents').respond([{
// //                                                       _id: '1',
// //                                                       mac_url: 'bsjiakmgr02.thoughtworks.com',
// //                                                       mac_status: 'idle',
// //                                                       ip_addr:'192.168.0.5',
// //                                                       catalog: '/var/lib/cruise-agent',
// //                                                       resources:['ubuntu','mysql','firefox']
// //                                                     }
// //                                                   ]);
// //         $httpBackend.when('POST','/agents').respond(200,'');
// //         $httpBackend.when('DELETE','/agents/1?resource=mysql').respond(204,'');
// //         //create an empty scope
// //         scope = $rootScope.$new();
// //         //declare the controller and inject our empty scope
// //         $controller('AgentsController', {$scope: scope});
// //         createController = function(){
// //           $controller('AgentsController', {$scope: {}});
// //         }
// //     }))
// //     // tests start here
// //     it('should agents to be empty', function(){
// //         expect(scope.agents.length).toBe(0);
// //     });

// //     it('should fetch list when create controller',function(){
// //         $httpBackend.expectGET('/agents');
// //         createController();
// //         $httpBackend.flush();
// //     })

// //     it('should fetch list of agents', function(){
// //         $httpBackend.flush();
// //         expect(scope.agents.length).toBe(1);
// //         expect(scope.agents[0]._id).toBe('1');
// //         expect(scope.agents[0].resources.length).toBe(3);
// //     });

// //     it('should insert new resource',function(){
// //         scope.insertResource('1','windows,IOS');
// //         timeout(function(){
// //           $httpBackend.flush();
// //           expect(scope.agents[0].resources.length).toBe(5);
// //         },500);
// //     })

// //     it('should not insert  resource',function(){
// //         scope.insertResource('1',',,,,,');
// //         scope.insertResource('1',', , , , ,');
// //         timeout(function(){
// //           $httpBackend.flush();
// //           expect(scope.agents[0].resources.length).toBe(3);
// //         },500);
// //     })

// //     it('should delete a resource',function(){
// //         $httpBackend.expectDELETE("/agents/1?resource=mysql").respond(204,'');
// //         scope.deleteResource('1','mysql');
// //         $httpBackend.flush();
// //         expect(scope.agents[0].resources.length).toBe(2);
// //     })

// //     it('delete a not exist resource',function(){
// //         $httpBackend.expectDELETE("/agents/1?resource=none").respond(204,'');
// //         scope.deleteResource('1','none');
// //         $httpBackend.flush();
// //         expect(scope.agents[0].resources.length).toBe(3);
// //     })



// });