Feature: Smoketest of hapi-fhir-jpaserver-starter

  Background:
    * configure ssl = false
    * configure report = { showLog: true, showAllSteps: true}

    * url 'http://localhost:8080/fhir'

  Scenario: CRUD Patient
    # Create patient
    # https://hapifhir.io/hapi-fhir/docs/server_plain/rest_operations.html#type_create
    Given path '/Patient'
    And def BodyOfRequest = read('smoketestfiles/patient_create.json')
    And request BodyOfRequest
    And header Content-Type = 'application/json'
    When method POST
    Then status 201
    And def single_patient_id = get response.id
    And def single_patient_identifier = get response.identifier[0].value
    And def single_patient_family_name = get response.name[0].family
    * print response
    * print single_patient_id
    * print single_patient_family_name
    * print single_patient_identifier
    And match $.meta.versionId == '1'

    # Search Single Patient'
    # https://hapifhir.io/hapi-fhir/docs/server_plain/rest_operations.html#type_search
    Given path '/Patient'
    And param name = single_patient_family_name
    And param identifier = single_patient_identifier
    And param _id = single_patient_id
    When method GET
    Then status 200
    And match $.total != 0

    # Delete Patient
    # https://hapifhir.io/hapi-fhir/docs/server_plain/rest_operations.html#instance_delete
    Given path '/Patient/' + single_patient_id
    When method DELETE
    Then status 200
    And match $.resourceType == 'OperationOutcome'
    And match $.issue[0].details.coding[0].code == 'SUCCESSFUL_DELETE'