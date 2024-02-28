Feature: Smoketest of hapi-fhir-jpaserver-starter

  Background:
    * configure ssl = false
    * configure report = { showLog: true, showAllSteps: true}

    * url 'http://localhost:8080/fhir'
    * def defXPPAgent = 'Di6KNVtdaGbSr43f5GudJryVrWT+MGEsRmiJCpbOAGYWxqzF/LIfSRU4d905zh5/ocvcAkNetsOv1zcboijFRw=='
    * def defUsername = '360d2294-fb82-4006-9c4b-29244e335d87'
    * def defPassword = '624cfc8fb9ec5048'
    * def defClientId = 'EHealthApp'
    * def defGrantType = 'password'
    * def defSignature = 'CeqhNpSd7s62MRa+jgztQnDIfVmvX9qBw1vtdQT7ssYjIqrG9TztI+54GPWTi/zAxnupcp4vCNd+Wo1muOXW0nr3j9FBixvKBKeSDbYRV2VmJjD1aZrcqrDOuS4ElmAdFj3/u5GV2yAw0DO2bvfVHhAlomiBCDN50JyoAUrWiTrC6LV9GKB4Lwj8yDm9W9IvQs52zJCcOmfVJ0NmJuclIX3O5b6SEktvaW8/+wJH+S2OB10J4mpOqtdkfI+GHZtE0PZ/7VEg+pHqZjItW7lI5TOiP2Vuraht9blxwTbuAFk8dmRFU2Qq2Ww7z2nP2pdA1GRy1Mfua/+Bb+uq6hX+Uw=='
    * def defPubKey = '-----BEGIN RSA PUBLIC KEY-----\\nMIIBCgKCAQEAlgmtdTwl7RieMeMVQoyV1QPQ4SmVxopQI1kPZD6qk9efB/C8kB9EYmb1mFy/\\nNvztk7d0MBbl9Pp1MrClsfvKZiQS30VjQh7amKVi+beqw7/ogF27zGvOCC+3HYdoPfhz48zx\\ndXTMjGoqkmZELIE7FzJWIEn3CUD00eLMFbFmbPGvggcHVxFxyQowwV7e6Q7zE/jZtJaFv9Ph\\nQ20TDUu4n4IPD1aYZmnqVWJm359Kn3jecw8f42jUQumZ6S/LnvZ3fsbQ7W61qw7RPxra+spL\\n+3IN/oFUEAKFIbGmlHJ4L/ihrxGmixgivC99Nb9Y8qY3SIIxWOEe1zPCsfaaHNa0xQIDAQAB\\n-----END RSA PUBLIC KEY-----'
    * def defClientVersion = '1.0.0'

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