*** Settings ***
Documentation       Template robot main suite.

Library             RPA.Browser.Selenium    auto_close=${FALSE}
Library             RPA.FileSystem
Library             RPA.Robocorp.WorkItems
Library             RPA.Windows
Library             Collections
Library             String
Library             RPA.Tables
Library             RPA.Outlook.Application
Library             datetime
Library             DateTime


*** Tasks ***
Bot-housing
    Open website    https://www.centris.ca/fr/propriete~a-vendre~mascouche?view=Thumbnail&uc=1
    Wait Until Element Is Visible    alias:Paragraph
    ${finalText}=    Set Variable    ${EMPTY}
    ${HouseCount}=    Set Variable    0
    ${houseLink}=    Set Variable    https://www.centris.ca/fr
    ${InitialHouseNumber}=    Set Variable    1
    ${HouseValue}=    Set Variable    0
    ${CurrentCity}=    Set Variable    St-Lin
    ${HousePicture}=    Set Variable    test123
    ${HouseFound}=    Set Variable    0
    ${InitialHouseNumber}=    Set Variable    1
    ${HouseTotalPerPage}=    Set Variable    20
    ${numberOfPage}=    Set Variable    1
    ${nouveauPrixExist}=    Set Variable    ${FALSE}
    ${nouvelleInscriptionExist}=    Set Variable    ${FALSE}
    ${collectionTable}=    Set Variable    ${NONE}
    ${DictHouseFound}=    Create Dictionary
    ${numberOfPageTotal}    ${totalHouseNumber}=    Centris - Get Number of pages
    WHILE    ${numberOfPage} <= ${numberOfPageTotal}
        Sleep    0.5s
        IF    ${HouseCount} == ${totalHouseNumber}    BREAK
        WHILE    ${InitialHouseNumber} <= ${HouseTotalPerPage}
            IF    ${HouseCount} == ${totalHouseNumber}    BREAK
            ${HouseCount}=    Evaluate    ${HouseCount} + 1
            ${nouvelleInscriptionExist}=    Is Element Text
            ...    //*[@id="divMainResult"]/div[${InitialHouseNumber}]/div/div[1]/div[1]
            ...    Nouvelle inscription
            ...    ${TRUE}
            ${nouveauPrixExist}=    Is Element Text
            ...    //*[@id="divMainResult"]/div[${InitialHouseNumber}]/div/div[1]/div[1]
            ...    Nouveau prix
            ...    ${TRUE}
            IF    ${nouvelleInscriptionExist} == ${TRUE} or ${nouveauPrixExist} == ${TRUE}
                ${HouseValue}=    RPA.Browser.Selenium.Get Text
                ...    //*[@id="divMainResult"]/div[${InitialHouseNumber}]/div/div[2]/a/div[2]/span[1]
                ${HousePicture}=    Get Element Attribute
                ...    //*[@id="divMainResult"]/div[${InitialHouseNumber}]/div/div[1]//a[1]/img
                ...    src
                ${houseLink}=    Get Element Attribute
                ...    //*[@id="divMainResult"]/div[${InitialHouseNumber}]/div/div[1]//a[1]
                ...    href
                ${HouseFound}=    Evaluate    ${HouseFound} + 1
                ${DictHouseFound}=    Set To Dictionary
                ...    ${DictHouseFound}
                ...    HouseFound=${HouseFound}
                ...    HouseValue=${HouseValue}
                ...    CurrentCity=${CurrentCity}
                ...    HousePicture=${HousePicture}
                ...    HouseLink=${houseLink}
                ${nouveauPrixExist}=    Set Variable    ${FALSE}
                ${nouvelleInscriptionExist}=    Set Variable    ${FALSE}
            END
            ${InitialHouseNumber}=    Evaluate    ${InitialHouseNumber} + 1
        END
        ${numberOfPage}=    Evaluate    ${numberOfPage} + 1
        ${InitialHouseNumber}=    Evaluate    1
        Click Element    alias:NextButton
    END
    Open Outlook
    Log List    ${DictHouseFound}
    ${date}=    Get Current Date    local    0    %d %B %Y    ${TRUE}
    ${DictLength}=    Get Length    ${DictHouseFound}
    ${HouseFound}=    Evaluate    0
    Log Dictionary    ${DictHouseFound}
    WHILE    ${HouseFound} == ${DictLength}
        ${HouseFound}=    Evaluate    ${HouseFound} + 1
    END
    Send Email    jessy2540@hotmail.com    ${HouseFound} maisons - ${date}    ${DictHouseFound}    ${TRUE}
    Quit Outlook


*** Keywords ***
Open website
    [Arguments]    ${URL}
    Open Available Browser    ${URL}    maximized=${TRUE}

Centris - Get Number of pages
    ${NumberOfHouse_string}=    RPA.Browser.Selenium.Get Text    alias:Paragraph
    ${NumberOfHouse_number}=    Convert To Integer    ${NumberOfHouse_string}
    ${NumberOfPage}=    Evaluate    (${NumberOfHouse_number}/20) + 1
    ${resultNumberPage}=    Convert To Integer    ${NumberOfPage}
    RETURN    ${resultNumberPage}    ${NumberOfHouse_number}

Open Outlook
    Open Application    ${TRUE}    ${FALSE}

Quit Outlook
    Quit Application    ${FALSE}

test
    Append To List
    ...    ${HouseList}
    ...    Nouvelle Propriété à ${HouseValue} - <br><a href="${houseLink}"> <img src="${HousePicture}" width="200" height="200"> </a> <br>
