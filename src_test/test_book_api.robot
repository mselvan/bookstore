*** Settings ***
Library           RequestsLibrary
Library           Collections

*** Variables ***
${BASE_URL}       http://localhost:8000
${AUTHOR}         Manimaran Selvan
${TITLE}          Autobiography of a Legend
${BOOK_ID}        1

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