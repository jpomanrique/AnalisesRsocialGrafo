# Instagram Graph Analysis -- Neo4j Project

## 📌 Overview

Este projeto implementa um modelo de grafo inspirado na estrutura do Instagram utilizando Neo4j e Cypher. O objetivo é demonstrar modelagem de grafos sociais, análise de centralidade, caminhos mínimos, engajamento e recomendações.
Desafio de Projeto: Analises de Redes Sociais

Este Produto: Oferece insights sobre engajamentos e conexões com base em usuários de uma plataforma. Construimos um protótipo funcional que possa responder a perguntas complexas sobre interações de usuários, popularidade de conteúdo e comunidades de interesse.

Objetivo:

Em lugar de ter uma tabela de usuários e informações você vai ter um grafo disso com:
        - Usuários(pessoas)
        - Posts
        - Grupos 
        - Comunidades

Uma pessoa segue a outra, uma pessoa publico algo, uma pessoa curtio algo, uma pessoa pertence a um grupo.
A pessoa curtio um post

Construimos algumas queries como:

    •	Como que as pessoas estão relacionadas
    •	Qual que e a menor distancia de uma pessoa para outra
    •	Se eu quisesse seguir 5 usuários. Como recomendaria os melhores 5 usuários, quais pessoas você recomendaria por que? Exemplo            através de um relacionamento de amizade indireta
    •	Qual foi a postagem mais curtida no ultimo mês com base num critério X, será que elas são amigos

- Como exemplo: Se eu sou amigo de uma pessoa A e ela esta relacionada com uma pessoa B, C, qual que o menor caminho como chego a pessoa E. Qual que e o menor caminho como devo recorrer para chegar a pessoa E

- Construimos um grafo para responder perguntas como: qual que e a menor distancia de uma pessoa para outra. Pode usar nós intermediários

------------------------------------------------------------------------

# 📂 Estrutura Final do Projeto

1. Visão Geral

Este projeto implementa a modelagem estrutural e análise de uma rede social inspirada no Instagram utilizando o modelo de dados em grafo do Neo4j. O objetivo não é apenas importar dados se considero construir uma representação semântica da rede, modelar interações sociais como relações direcionadas, garantir integridade estrutural via constraints, executar análises de engajamento e centralidade e validar consistência estrutural do grafo.

O arquivo principal do projeto é: instagram.cypher. Ele está organizado em blocos lógicos com responsabilidades bem definidas.

2. Arquitetura do Grafo
    2.1 Labels (Entidades)
        Label	Representa
        User	Usuários da plataforma
        Post	Publicações (photos)
        Tag	Hashtags associadas aos posts
    2.2 Relações
        Relação	Direção	Significado
        POSTED	(User → Post)	Usuário publicou um post
        LIKED	(User → Post)	Usuário curtiu um post
        COMMENTED	(User → Post)	Usuário comentou um post
        HAS_TAG	(Post → Tag)	Post contém determinada tag
        2.3 Modelo Estrutural
        (User)-[:POSTED]->(Post)
        (User)-[:LIKED]->(Post)
        (User)-[:COMMENTED]->(Post)
        (Post)-[:HAS_TAG]->(Tag)


Essa modelagem permite:

        Análise de engajamento
        Identificação de conteúdo popular
        Análise de afinidade por tags
        Exploração de padrões estruturais

3. Estrutura do instagram.cypher

O arquivo está dividido em quatro grandes blocos.

    BLOCO 1 – Definição do Schema (Constraints)

        Este bloco estabelece constraints de unicidade para:

            User.id
            Post.id
            Tag.id

Justificativa

            Garante integridade dos dados
            Evita duplicação acidental durante MERGE  
            Melhora performance de consultas
            Permite execução idempotente do script

Sem esse bloco, múltiplas execuções poderiam gerar inconsistências.

BLOCO 2 – Importação e Construção do Grafo

Este é o núcleo estrutural do projeto.

Ele realiza:

            Criação de nós (Users, Posts, Tags)
            Conversão de tipos (string → integer, datetime)
            Construção das relações sociais

2A – Importação de Users

            Cria nós User
            Converte id para inteiro
            Define username

Uso de MERGE garante idempotência.

2B – Importação de Posts

            Cria nós Post
            Converte user_id para inteiro
            Converte created_at para datetime

A conversão:

datetime(replace(row.created_at, " ", "T")) é necessária porque o Neo4j exige padrão ISO-8601.

2C – Relação POSTED

            Relaciona usuários aos seus posts com base no user_id armazenado no nó Post.
            Essa abordagem evita múltiplas leituras do CSV.

2D – Importação de Likes

            Modela interação passiva (engajamento leve).
            Representa graficamente popularidade de conteúdo.

2E – Importação de Comments

            Modela interação ativa (engajamento forte).
            Permite análises comparativas entre curtidas e comentários.

2F – Importação de Tags

            Cria nós Tag independentes.

2G – Associação Post–Tag

Permite:

            Análise temática
            Descoberta de padrões de conteúdo
            Identificação de tendências

BLOCO 3 – Consultas Analíticas

Este bloco realiza análises estruturais e métricas de engajamento.

Exemplos de perguntas respondidas:

            Qual o post mais curtido?
            
            Quais usuários são mais ativos?
            
            Qual a distribuição de interações?
            
            Qual a relação entre tags e popularidade?

Essas consultas demonstram exploração de padrões no grafo, não apenas contagem simples.

BLOCO 4 – Testes Estruturais

            Contém consultas auxiliares para:
            Verificação de integridade
            Validação de intervalos de IDs
            Conferência de relacionamentos

Esse bloco funciona como auditoria estrutural.

4. Decisões de Modelagem
Por que modelar likes e comments como relações?

Porque em grafos:

            Interações são naturalmente representadas como edges
            Permite análise de grau (degree)
            Facilita cálculo de centralidade

Por que armazenar user_id no Post antes de criar POSTED?

Para separar:

            Criação de entidades
            Construção de relações
            Isso melhora clareza e manutenção.

5. Propriedades Relevantes
            Entidade	Propriedade	Tipo
            User	id	Integer
            User	username	String
            Post	id	Integer
            Post	image_url	String
            Post	created_at	Datetime
            Tag	id	Integer
            Tag	tag_name	String
6. Como Executar

            Coloque os CSVs na pasta import de seu directorio de importação para Neo4j
                   follows.csv
                   likes.csv
                   photo_tags.csv
                   photos.csv
                   tags.csv
                   users.csv;
            Execute os blocos em ordem sequencial
            Verifique se constraints foram criadas
            Execute análises

8. Resultados Esperados

            Após execução completa:
            Grafo conectado entre usuários e posts
            Estrutura pronta para análise de redes     
            Dados temporalmente consistentes
            Interações representadas como relações direcionadas

9. Potenciais Extensões

            Cálculo de PageRank
            Centralidade de grau
            Comunidades (Louvain)
            Recomendação de conteúdo
            Detecção de influenciadores

10. Conclusão

Este projeto demonstra a modelagem de rede social em banco de dados orientado a grafos, construção estruturada de dados, aplicação de constraints assim mesmo executa análise de padrões de interação com base em estudos avançados de análise de redes sociais.

## Bloco 01: Responsável por:

-   Criação de constraints
-   Definição de unicidade (User.id)
-   Preparação da base estrutural do grafo
   
# ⚙️ Ordem de Execução Recomendada

Este arquivo deve ser executado por partes por exemplo bloco 1A e logo bloco 2A, o outros bloco 2A logo 2b e aassim sucesivamente em Neo4j. a versao de Neo4j fo a 2.1.1 Desktop

------------------------------------------------------------------------

## Bloco 02: Responsável por:

-   Criação de usuários principais
-   Criação de posts
-   Criação de relações:
    -   FOLLOWS
    -   POSTED
    -   LIKES
    -   COMMENTS
-   Inserção de dados iniciais para análise

------------------------------------------------------------------------

## Bloco 03 de analises. Responsável por:

-   Degree Centrality (in-degree / out-degree)
-   Shortest Path
-   Recomendações baseadas em amigos de amigos
-   Cálculo de engajamento
-   Consultas analíticas gerais

Contém as principais análises do projeto.

------------------------------------------------------------------------

## Bloco 04. Responsável por:

-   Criação de 7 usuários artificiais (IDs 2000--2006)
-   Criação de estrutura linear FOLLOWS: 2000 → 2001 → 2002 → 2003 →
    2004 → 2005 → 2006
-   Verificação estrutural da rede e otras consultas Cypher

Utilizado para testar algoritmos de caminho e centralidade de forma
controlada.
------------------------------------------------------------------------

## BLOCO 5. Estrutura Social e InteraçõesResponsável por:


Incluir análises como:

                        Interações entre usuários
                        Relações bidirecionais
                        Influência social
------------------------------------------------------------------------

## BLOCO 6 – Popularidade. Responsável por:
                        6A – Post mais curtido (últimos 30 dias)
                                WHERE p.created_at >= datetime() - duration('P30D')
                        
                        6B – Tags mais populares
                                Ordenação por número de posts associados.

------------------------------------------------------------------------

## BLOCO 7 – Comunidades e Métricas. Responsável por:

Incluir:

                        Centralidade ampliada
                        Caminhos adicionais
                        Análises estruturais
                        
------------------------------------------------------------------------

# 🧠 Conceitos Aplicados

-   Modelagem de Grafos Sociais
-   Relacionamentos direcionais
-   Degree Centrality
-   Shortest Path
-   Análise de Engajamento
-   Recomendação baseada em vizinhança

------------------------------------------------------------------------
# 🔒 Boas Práticas Aplicadas

-   Uso de MERGE para evitar duplicações
-   Uso de OPTIONAL MATCH para evitar falhas
-   Organização em blocos numerados
-   Estrutura idempotente
-   Compatível com Neo4j 4.x e 5.x

------------------------------------------------------------------------

# 🎯 Status Final

✔ Estrutura modularizada\
✔ Código revisado e corrigido\
✔ Sem duplicações críticas\
------------------------------------------------------------------------

# 👤 Autor

John Peter Oyardo Omanrique
jpomanrique@gmail.com

------------------------------------------------------------------------

Projeto final consolidado e validado.
