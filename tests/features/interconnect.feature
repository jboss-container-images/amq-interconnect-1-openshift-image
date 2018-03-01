@amq-interconnect-1
Feature: Configuration tests

  Scenario: Check that Router config can be updated
    When container is started with env
       | variable     | value     |
       | ROUTER_ID    | Router.B  |
       | ROUTER_MODE  | interior  |
    Then container log should contain Container Name: Router.B
    And container log should contain Router started in Interior mode
