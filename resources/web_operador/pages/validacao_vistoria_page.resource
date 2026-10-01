*** Settings ***
Documentation     Mapeamento dos elementos da página de validação de vistoria web.

*** Variables ***
${VALIDACAO_TITULO}     xpath=//h1[contains(.,'Validação de Vistoria')]
${BOTAO_APROVAR}       xpath=//button[contains(.,'Aprovar')]
${BOTAO_REPROVAR}      xpath=//button[contains(.,'Reprovar')]
${CAMPO_COMENTARIO}    id=observacao
