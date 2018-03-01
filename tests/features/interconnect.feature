@amq-interconnect-1
Feature: Configuration tests

	#Scenario: Check that Router ID can be updated
	# When container is started with env
	# | variable     | value     |
	# | ROUTER_MODE  | interior  |
	#Then container log should contain Router started in Interior mode
	
  Scenario: Check that Router ID can be updated
    When container is started with env
       | variable     | value     |
       | ROUTER_ID    | Router.B  |
    Then container log should contain Container Name: Router.B

    # Scenario: Check that ports are available
    #When container is ready
    #Then check that port 56720 is open
    #Then check that port 8080  is open
