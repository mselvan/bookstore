*** Settings ***
Library           RequestsLibrary
Library           Collections
Suite Setup       Reset Book Store
Suite Teardown    Reset Book Store

*** Variables ***
${BASE_URL}       http://localhost:8000
${AUTHOR}         Muthu Kamatchi Manickam
${TITLE}          Autobiography
${BOOK_ID}        123

*** Keywords ***
Reset Book Store
    DELETE    ${BASE_URL}/api/books

*** Test Cases ***
Verify That The API Starts With An Empty Store
    [Documentation]    Validate that the API starts with an empty store
    ${response}=       GET    ${BASE_URL}/api/books
    Status Should Be   200    ${response}
    Should Be Empty    ${response.json()}
    Log to Console    Book Store is empty as expected

Verify That The Title Is A Required Field
    [Documentation]    Validate that the title is required field for creating book
    ${payload}=        Create Dictionary    author=${AUTHOR}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Be Equal As Strings    ${response.json()["error"]}    Field \"title\" is required
    Log to Console   The title is required field

Verify That The Author Is A Required Field
    [Documentation]    Validate that the title is required field for creating book
    ${payload}=        Create Dictionary    title=${TITLE}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Be Equal As Strings    ${response.json()["error"]}    Field \"author\" is required
    Log to Console   The author is required field

Verify That The Title Cannot Be Empty
    [Documentation]    Validate that the title cannot be empty
    ${payload}=        Create Dictionary    title=
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Be Equal As Strings    ${response.json()["error"]}    Field \"title\" cannot be empty
    Log to Console   The title cannot be empty

Verify That The Author Cannot Be Empty
    [Documentation]    Validate that the author cannot be empty
    ${payload}=        Create Dictionary    author=
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Be Equal As Strings    ${response.json()["error"]}     Field \"author\" cannot be empty
    Log to Console   The author cannot be empty

Verify That The ID Field Is Read-Only
    [Documentation]    Validate that the 'id' field cannot be changed by the client
    ${payload}=        Create Dictionary    id=${BOOK_ID}    title=${TITLE}   author=${AUTHOR}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Be Equal As Strings    ${response.json()["error"]}    Field \"id\" is read-only
    Log to Console     ID is read only

Verify That New Book Can Be Created
    [Documentation]    Validate that the client can ceate a new book
    ${payload}=        Create Dictionary    title=${TITLE}   author=${AUTHOR}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}
    Status Should Be   200    ${response}
    Should Be Equal As Strings    ${response.json()["author"]}    ${AUTHOR}
    Should Be Equal As Strings    ${response.json()["title"]}     ${TITLE}
    Log to Console      Book created successfully

Verify That Duplicate Book Cannot Be Created
    [Documentation]    Validate that the duplicate book
    ${payload}=        Create Dictionary    title=${TITLE}   author=${AUTHOR}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Be Equal As Strings    ${response.json()["error"]}   Another book with similar title and author already exists
    Log to Console    Duplicate book cannot be created