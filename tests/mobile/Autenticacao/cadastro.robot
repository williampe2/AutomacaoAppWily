*** Settings ***
Documentation    Jornada completa validando cadastro, travas de login, recuperacao de senha e exclusao de conta.
Resource         ../../../resources/shared/setup_teardown.resource
Resource         ../../../resources/app/actions/auth_actions.resource
Variables        ../../../config/secrets.yaml
Variables        ../../../resources/data/perfis_usuarios.yaml
Test Setup       Abrir Aplicativo Wily no Emulador
Test Teardown    Fechar Aplicativo Wily

*** Test Cases ***
Cenario: Jornada de Autenticacao Completa
    [Tags]    mobile    jornada_autenticacao
    
    # 1. CADASTRO
    Dado que o usuario realiza o cadastro completo com "${EMAIL_QA}" e "${SENHA_QA}"
    Entao a conta deve ser criada e redirecionada para a Home
    
    # 2. LOGOUT
    Quando o usuario realiza o Logout pelo menu hamburguer
    Entao deve ser redirecionado para a tela de Boas Vindas
    
    # 3. LOGIN INVÁLIDO
    Quando tenta fazer login com "${EMAIL_QA}" e a senha incorreta "SenhaErrada000"
    Entao o sistema deve exibir mensagem de erro de credenciais invalidas
    
    # 4. RECUPERAÇÃO DE SENHA
    Quando o usuario solicita a recuperacao de senha para "${EMAIL_QA}"
    E o robo pega o codigo OTP de recuperacao
    E define a nova senha "${NOVA_SENHA_QA}"
    
    # 5. LOGIN COM NOVA SENHA
    E faz login novamente com "${EMAIL_QA}" e "${NOVA_SENHA_QA}"
    Entao o acesso deve ser concedido para a Home
    
    # 6. EXCLUSÃO E TEARDOWN DE DADOS
    Quando o usuario solicita a exclusao permanente da conta
    Entao o sistema deve apagar os dados e retornar para a tela de Boas Vindas