# Sistema de Controle de Usuários e Produtos - WM10

# Sistema de Controle de Produtos - Teste Full Stack WM10

## Descrição

Aplicação web full stack para gerenciamento de produtos, desenvolvida para demonstrar sólidos conhecimentos de fundamentos de desenvolvimento, segurança e boas práticas de arquitetura utilizando uma stack legada.

O projeto inclui um backend em **ASP Clássico** que serve uma API RESTful, um banco de dados **SQL Server** com lógica de negócio em Stored Procedures, e um frontend **Single-Page Application (SPA)** construído com HTML, Bootstrap e jQuery.

## Estrutura do Projeto
/projeto-wm10/
|-- /backend/
|   |-- /api/
|   |   |-- auth.asp
|   |   |-- products.asp
|   |-- /includes/
|   |   |-- db.asp
|   |   |-- json.class.asp
|   |-- web.config
|-- /database/
|   |-- script.sql
|-- /docs/
|   |-- WM10_API.postman_collection.json
|-- /frontend/
|   |-- /css/
|   |   |-- style.css
|   |-- /js/
|   |   |-- app.js
|   |   |-- auth.js
|   |   |-- products.js
|   |   |-- router.js
|   |-- /views/
|   |   |-- login.html
|   |   |-- product-form.html
|   |   |-- products-list.html
|   |   |-- register.html
|   |-- index.html
|-- .gitignore
|-- README.md

---

## Tecnologias Utilizadas

- **Backend:** ASP Clássico (VBScript)
- **Servidor Web:** Microsoft IIS (Internet Information Services)
- **Frontend:** HTML5, CSS3, Bootstrap 5, jQuery
- **Database:** Microsoft SQL Server
- **IDE:** Visual Studio 2022
- **Ferramentas:** SQL Server Management Studio (SSMS), Postman

---

## Estrutura do Banco de Dados

### Tabela `users`
Armazena informações dos usuários registrados.

- `id` (INT, PK, Identity)
- `name` (VARCHAR(100), NOT NULL)
- `email` (VARCHAR(100), UNIQUE, NOT NULL)
- `password_hash` (VARCHAR(255), NOT NULL)
- `created_at` (DATETIME, DEFAULT GETDATE())

### Tabela `products`
Armazena informações sobre os produtos disponíveis.

- `id` (INT, PK, Identity)
- `name` (VARCHAR(150), NOT NULL)
- `description` (TEXT, opcional)
- `price` (DECIMAL(10,2), NOT NULL)
- `stock` (INT, NOT NULL)
- `created_at` (DATETIME, DEFAULT GETDATE())
- `updated_at` (DATETIME, DEFAULT GETDATE())

### Tabela `logs`
Registra todas as operações de alteração nos produtos.

- `id` (INT, PK, Identity)
- `product_id` (INT, FK → products.id)
- `operation` (VARCHAR(10), NOT NULL)
- `log_data` (VARCHAR(500))
- `changed_by` (VARCHAR(100))
- `log_date` (DATETIME, DEFAULT GETDATE())

---

## Procedures Criadas

### `add_user`
Adiciona um novo usuário, verificando se o e-mail já está cadastrado.

### `login_user`
Realiza o login de um usuário, validando `email` e `password_hash`.

---

## Triggers Criadas

### `log_update`
Registra no log sempre que um produto é atualizado.

### `log_delete`
Registra no log sempre que um produto é deletado.

---

## Funções

### `fn_validate_token`
Valida um token simples (exemplo de autenticação).

---

## Como Usar - 

1. Execute o script SQL no SQL Server Management Studio (SSMS) ou ambiente compatível.
2. As tabelas, procedures, triggers e funções serão criadas automaticamente.
3. Para inserir um usuário:
   ```sql
   EXEC add_user @name = 'João Teste', @email = 'joao@email.com', @password_hash = '123456';
   ```
4. Para realizar login:
   ```sql
   EXEC login_user @email = 'joao@email.com', @password_hash = '123456';
   ```
5. Para atualizar ou deletar um produto, os logs serão gerados automaticamente.
6. Para validar um token:
   ```sql
   SELECT dbo.fn_validate_token('meu_token_de_teste');
   ```

---

## Instruções de Setup (Passo a Passo)

Essa parte decidi elaborar para garantir uma configuração de ambiente limpa e funcional, antecipando os problemas mais comuns que passei (como o erro 500 genérico) encontrados em ambientes de desenvolvimento Windows (o meu).

### Passo 1: Configuração do Banco de Dados (SQL Server)

1.  **Instale o SQL Server Express e o SSMS:**
    * Baixe e instale o [SQL Server Express Edition](https://www.microsoft.com/pt-br/sql-server/sql-server-downloads). A básica é suficiente.
    * Baixe e instale o [SQL Server Management Studio (SSMS)](https://learn.microsoft.com/pt-br/sql/ssms/download-sql-server-management-studio-ssms).

2.  **Conecte-se e Habilite o Modo Misto:**
    * Abra o SSMS e conecte-se no seu servidor local (ex: `localhost\SQLEXPRESS`).
    * **Dica:** Em instalações novas, ao conectar, clique em "Opções >>" e na aba "Propriedades de Conexão", marque a caixa **"Certificado de servidor confiável"** para evitar os erros de SSL.
    * Clique com o botão direito no nome do servidor -> **Propriedades** -> **Segurança**. Marque a opção **"Modo de Autenticação do SQL Server e do Windows"** e clique em OK.

3.  **Reinicie o Serviço do SQL Server:**
    * Abra o **SQL Server Configuration Manager**, vá em "SQL Server Services", clique com o botão direito em "SQL Server (SQLEXPRESS)" e escolha **"Reiniciar"**.

4.  **Execute o Script do Banco de Dados:**
    * No SSMS, crie um novo banco de dados chamado `projeto_db`.
    * Abra o arquivo `/database/script.sql` do projeto.
    * Garanta que o banco `projeto_db` está selecionado na barra de ferramentas e execute o script.

5.  **Crie o Usuário da Aplicação:**
    * No SSMS, vá em **Segurança -> Logons**.
    * Clique com o botão direito -> Novo Logon.
    * **Nome de Logon:** `api_user`
    * Marque **"Autenticação do SQL Server"**.
    * Defina uma senha (ex: `apisenha123`).
    * Desmarque "Impor política de senha".
    * Vá para **"Mapeamento de Usuário"**, marque o banco `projeto_db` e, na parte de baixo, marque a função `db_owner`.
    * Clique em OK.

### Passo 2: Configuração do Ambiente Web (IIS)

1.  **Ative os Recursos do IIS:**
    * Vá em "Ativar ou desativar recursos do Windows".
    * Navegue até "Serviços de Informações da Internet" e ative os recursos:
        * Em `Serviços da World Wide Web > Recursos de Desenvolvimento de Aplicativos`, marque **`ASP`**.
        * Em `Serviços da World Wide Web > Segurança`, marque **`Autenticação do Windows`**.

2.  **Configure o Site:**
    * Abra o Gerenciador do IIS (`inetmgr`).
    * Clique com o botão direito em "Sites" -> Adicionar Site.
    * **Nome do site:** `projeto-wm10-backend` (sugestão, ok? 😅)
    * **Caminho Físico:** Aponte para a pasta `\backend` deste projeto.
    * **Porta:** `80` (ou a que você achar melhor).
    * Clique em OK.

3.  **Ajuste de Permissões e Configurações Críticas:**
    * No IIS, clique em **"Pools de Aplicativos"**. Selecione o pool do seu site (geralmente `DefaultAppPool`), clique em "Configurações Avançadas" e mude **"Habilitar Aplicativos de 32 Bits"** para `True`.
    * Volte para o seu site, vá em **"Autenticação"**, desabilite a "Autenticação do Windows" e deixe só a **"Autenticação Anônima" habilitada**. Clique nela, vá em "Editar" e garanta que está usando a **"Identidade do pool de aplicativos"**.

---

### Passo 3: Configuração do Projeto

1.  **Clone o Repositório:** `git clone https://github.com/seu-usuario/projeto-wm10.git`
2.  **Atualize a Connection String:**
    * Abra o arquivo `/backend/includes/db.asp`.
    * Na `connString`, verifique se o `User ID` e `Password` correspondem EXATAMENTE ao que foi configurado no Passo 1.

---

## Solução de Problemas (Como Evitar o Erro 500 Genérico ou outros erros malucos do ASP)

Durante o desenvolvimento, enfrentei um erro 500 persistente. A causa raiz era a ausência das diretivas `#include` nos arquivos de API, um problema fundamental na estrutura do código.

**Se você encontrar qualquer erro 500, verifique nesta ordem:**
1.  **Includes no Topo do Arquivo:** Garanta que os arquivos `auth.asp` e `products.asp` começam com as linhas `` **antes** de qualquer bloco `<% ... %>`. Esta foi a causa final do nosso problema.
2.  **Permissões de Pasta:** Se o erro for **500.19**, vá para a pasta raiz do projeto, clique com o botão direito -> Propriedades -> Segurança, e dê permissões de "Leitura e execução" para o grupo `IIS_IUSRS`.
3.  **Connection String:** Um erro 500 pode ser causado por uma senha ou nome de usuário incorreto no arquivo `db.asp`.
4.  **Codificação de Arquivo:** Garanta que todos os arquivos `.asp` estão salvos com a codificação **UTF-8 sem BOM**.

---

## Como Executar e Testar

### Executando o Frontend
Basta abrir o arquivo `/frontend/index.html` em um navegador web moderno (Chrome, Firefox, Edge).

### Testando a API com Postman
A maneira mais fácil de testar os endpoints do backend é importar a coleção fornecida.
1.  Abra o Postman.
2.  Vá em **File -> Import...**.
3.  Selecione o arquivo `/docs/WM10_API.postman_collection.json`.
4.  Uma nova coleção chamada "Projeto WM10" aparecerá, com todas as requisições prontas para serem executadas. Lembre-se de que as rotas de produtos precisam de um token de autorização, que pode ser obtido na resposta da requisição de "Login".

---

## Endpoints da API

| Método | Rota                                      | Descrição                      | Requer Token? |
| :----- | :---------------------------------------- | :------------------------------- | :-----------: |
| `POST` | `/api/auth.asp?action=register`           | Registra um novo usuário.        |      Não      |
| `POST` | `/api/auth.asp?action=login`              | Autentica um usuário.            |      Não      |
| `GET`  | `/api/products.asp`                       | Lista todos os produtos.         |      Sim      |
| `GET`  | `/api/products.asp?id={id}`               | Retorna um produto específico.   |      Sim      |
| `POST` | `/api/products.asp`                       | Cria um novo produto.            |      Sim      |
| `PUT`  | `/api/products.asp?id={id}`               | Atualiza um produto existente.   |      Sim      |
| `DELETE`| `/api/products.asp?id={id}`              | Deleta um produto.               |      Sim      |

---

## Conformidade

Este sistema está em conformidade com os requisitos solicitados:
- Autenticação de usuários (registro e login);
- CRUD de produtos (com logs automáticos para `UPDATE` e `DELETE`);
- Registro de auditoria (tabela `logs`);
- Validação básica de token.

---

📌 **Autor:** Pedro Rigo  
**Data:** 20/08/2025
