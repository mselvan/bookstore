*** Settings ***
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000
${AUTHOR}         Manimaran Selvan
${TITLE}          Autobiography of a Legend
${BOOK_ID}        123

*** Test Cases ***
Verify That The API Starts With An Empty Store
    [Documentation]    Validate that the API starts with an empty store
    ${response}=       GET    ${BASE_URL}/api/books
    Status Should Be   200    ${response}
    ${json}=        To JSON   ${response.content}
    Length Should Be   ${json}   0
    Log to Console    Book Store is empty as expected

Verify That Title Is Required Fields
    [Documentation]    Validate that the title is required field for creating book
    ${payload}=        Create Dictionary    author=${AUTHOR}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Contain    ${response.text}    title
    Log to Console   The title is required field

Verify That Author Is Required Fields
    [Documentation]    Validate that the title is required field for creating book
    ${payload}=        Create Dictionary    title=${TITLE}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Contain    ${response.text}    author
    Log to Console   The author is required field

Verify That Title Cannot Be Empty
    [Documentation]    Validate that the title cannot be empty
    ${payload}=        Create Dictionary    title=
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Contain    ${response.text}    title
    Log to Console   The title cannot be empty

Verify That Author Cannot Be Empty
    [Documentation]    Validate that the author cannot be empty
    ${payload}=        Create Dictionary    author=
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Contain    ${response.text}    author
    Log to Console   The author cannot be empty

Verify That ID Field Is Read-Only
    [Documentation]    Validate that the 'id' field cannot be changed by the client
    ${payload}=        Create Dictionary    id=${BOOK_ID}    title=${TITLE}   author=${AUTHOR}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Contain    ${response.text}    id
    Log to Console     ID is read only

Verify That New Book Can Be Created
    [Documentation]    Validate that the client can ceate a new book
    ${payload}=        Create Dictionary    title=${TITLE}   author=${AUTHOR}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   200    ${response}
    Log to Console      Book created successfully

Verify That Duplicate Book Cannot Be Created
    [Documentation]    Validate that the duplicate book
    ${payload}=        Create Dictionary    title=${TITLE}   author=${AUTHOR}
    ${headers}=        Create Dictionary    Content-Type=application/json
    ${response}=       PUT    ${BASE_URL}/api/books   json=${payload}    headers=${headers}     expected_status=any
    Status Should Be   400    ${response}
    Should Contain    ${response.text}    Another book with similar title and author already exists
    Log to Console    Duplicate book cannot be created