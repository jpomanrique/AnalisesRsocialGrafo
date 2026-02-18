/* ======================================================
BLOCO 1 – CONSTRAINTS E ESTRUTURA
====================================================== */ 
/* ------------------------------------------------------
   1A – Constraints (evita duplicação)
------------------------------------------------------ */

CREATE CONSTRAINT user_id IF NOT EXISTS
FOR (u:User) REQUIRE u.id IS UNIQUE;

CREATE CONSTRAINT post_id IF NOT EXISTS
FOR (p:Post) REQUIRE p.id IS UNIQUE;

CREATE CONSTRAINT tag_id IF NOT EXISTS
FOR (t:Tag) REQUIRE t.id IS UNIQUE;

/* ======================================================
BLOCO 2 – IMPORTAÇÃO DOS DADOS
====================================================== */
/* ------------------------------------------------------
   2A – Importar Users 
------------------------------------------------------ */
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
MERGE (u:User {id: toInteger(row.id)})
SET u.username = row.username;

/* ------------------------------------------------------
   2B – Importar Posts (photos.csv) 
------------------------------------------------------ */
LOAD CSV WITH HEADERS FROM 'file:///photos.csv' AS row
MERGE (p:Post {id: toInteger(row.id)})
SET p.image_url  = row.image_url,
    p.user_id    = toInteger(row.user_id),
    p.created_at = datetime(replace(row.created_at, " ", "T"));

/* ------------------------------------------------------
   2C – Criar relação POSTED(photos.csv) 
------------------------------------------------------ */

MATCH (p:Post)
MATCH (u:User {id: p.user_id})
MERGE (u)-[:POSTED]->(p);

/* ------------------------------------------------------
   2D – Importar Likes
------------------------------------------------------ */

LOAD CSV WITH HEADERS FROM 'file:///likes.csv' AS row
MATCH (u:User {id: toInteger(row.user_id)})
MATCH (p:Post {id: toInteger(row.photo_id)})
MERGE (u)-[:LIKED]->(p);

/* ------------------------------------------------------
   2E – Importar Comments
------------------------------------------------------ */

LOAD CSV WITH HEADERS FROM 'file:///comments.csv' AS row
MATCH (u:User {id: toInteger(row.user_id)})
MATCH (p:Post {id: toInteger(row.photo_id)})
MERGE (u)-[:COMMENTED]->(p);

/* ------------------------------------------------------
   2F – Importar Tags
------------------------------------------------------ */

LOAD CSV WITH HEADERS FROM 'file:///tags.csv' AS row
MERGE (t:Tag {id: toInteger(row.id)})
SET t.tag_name = row.tag_name;

/* ------------------------------------------------------
   2G – Relacionar Post com Tags
------------------------------------------------------ */

LOAD CSV WITH HEADERS FROM 'file:///photos_tags.csv' AS row
MATCH (p:Post {id: toInteger(row.photo_id)})
MATCH (t:Tag  {id: toInteger(row.tag_id)})
MERGE (p)-[:HAS_TAG]->(t);
/* ======================================================
BLOCO 3 – VALIDAÇÃO E VERIFICAÇÃO 
====================================================== */
/* ------------------------------------------------------
   3A – Contagem de Nós
------------------------------------------------------ */
MATCH (u:User) RETURN count(u) AS total_users;
MATCH (p:Post) RETURN count(p) AS total_posts;
MATCH (t:Tag)  RETURN count(t) AS total_tags;

/* ------------------------------------------------------
   3B – Contagem de Relações
------------------------------------------------------ */

MATCH ()-[r:POSTED]->() RETURN count(r) AS total_posted;
MATCH ()-[r:LIKED]->() RETURN count(r) AS total_likes;
MATCH ()-[r:COMMENTED]->() RETURN count(r) AS total_comments;
MATCH ()-[r:HAS_TAG]->() RETURN count(r) AS total_tags_rel;

/* ------------------------------------------------------
   3C – Verificar Datas
------------------------------------------------------ */

MATCH (p:Post)
RETURN min(p.created_at) AS mais_antigo,
       max(p.created_at) AS mais_recente;

/* ------------------------------------------------------
   3D – Verificação de Integridade
------------------------------------------------------ */

/* Posts sem usuário: */
MATCH (p:Post)
WHERE NOT (p)<-[:POSTED]-(:User)
RETURN p.id;
/* Usuários sem posts: */
MATCH (u:User)
WHERE NOT (u)-[:POSTED]->(:Post)
RETURN u.id;

/* ======================================================
BLOCO 4 – CENTRALIDADE, CAMINHOS E RECOMENDAÇÕES (CORRIGIDO)
====================================================== */

/* ------------------------------------------------------
   4i – Criar usuários artificiais para testes
   (idempotente – usa MERGE)
------------------------------------------------------ */

MERGE (:User {id:2000, username:'A'});
MERGE (:User {id:2001, username:'B'});
MERGE (:User {id:2002, username:'C'});
MERGE (:User {id:2003, username:'D'});
MERGE (:User {id:2004, username:'E'});
MERGE (:User {id:2005, username:'F'});
MERGE (:User {id:2006, username:'G'});


/* ------------------------------------------------------
   4ii – Criar relações FOLLOWS (estrutura linear)
   2000 → 2001 → 2002 → 2003 → 2004 → 2005 → 2006
------------------------------------------------------ */

MATCH (a:User {id:2000}), (b:User {id:2001})
MERGE (a)-[:FOLLOWS]->(b);

MATCH (a:User {id:2001}), (b:User {id:2002})
MERGE (a)-[:FOLLOWS]->(b);

MATCH (a:User {id:2002}), (b:User {id:2003})
MERGE (a)-[:FOLLOWS]->(b);

MATCH (a:User {id:2003}), (b:User {id:2004})
MERGE (a)-[:FOLLOWS]->(b);

MATCH (a:User {id:2004}), (b:User {id:2005})
MERGE (a)-[:FOLLOWS]->(b);

MATCH (a:User {id:2005}), (b:User {id:2006})
MERGE (a)-[:FOLLOWS]->(b);


/* ------------------------------------------------------
   4iii– Verificação da estrutura criada
------------------------------------------------------ */

MATCH (u:User)
WHERE u.id >= 2000 AND u.id <= 2006
OPTIONAL MATCH (u)-[out:FOLLOWS]->()
WITH u, COUNT(out) AS out_degree
OPTIONAL MATCH (u)<-[in:FOLLOWS]-()
RETURN u.id AS user_id,
       out_degree,
       COUNT(in) AS in_degree
ORDER BY user_id;


:param userA => 1;
:param userB => 50;
:param userE => 80;
:param me => 10;

/* ------------------------------------------------------
   4A – Degree Centrality (compatível)
------------------------------------------------------ */

MATCH (u:User)
OPTIONAL MATCH (u)-[out:FOLLOWS]->()
WITH u, COUNT(out) AS out_degree
OPTIONAL MATCH (u)<-[in:FOLLOWS]-()
RETURN u.id AS user_id,
       out_degree,
       COUNT(in) AS in_degree
ORDER BY in_degree DESC
LIMIT 10;

/* ------------------------------------------------------
   4B – Menor caminho (userA → userB)
------------------------------------------------------ */

MATCH (a:User {id:$userA}), (b:User {id:$userB})
MATCH path = shortestPath((a)-[*..5]-(b))
RETURN [n IN nodes(path) | labels(n)[0] + ':' + n.id] AS caminho,
       length(path) AS passos;

/* ------------------------------------------------------
   4C – Recomendação (amigos de amigos)
------------------------------------------------------ */

/* usar parâmetro $me*/
MATCH (me:User {id:$me})-[:FOLLOWS]->(:User)-[:FOLLOWS]->(rec:User)
WHERE NOT (me)-[:FOLLOWS]->(rec)
  AND me <> rec
RETURN rec.id AS recomendado,
       COUNT(rec) AS score
ORDER BY score DESC
LIMIT 10;

/* ------------------------------------------------------
   4D – Caminho (userA → userE)
------------------------------------------------------ */

MATCH (a:User {id:$userA}), (b:User {id:$userE})
MATCH path2 = shortestPath((a)-[*..5]-(b))
RETURN [n IN nodes(path2) | labels(n)[0] + ':' + n.id] AS caminho,
       length(path2) AS passos;

/* ------------------------------------------------------
   4E – Usuário mais central (engajamento real)
------------------------------------------------------ */

/* likes e comentários que o usuário RECEBEU . */
MATCH (u:User)

OPTIONAL MATCH (u)-[:POSTED]->(p:Post)
WITH u, COUNT(DISTINCT p) AS posts

OPTIONAL MATCH (u)-[:POSTED]->(p2:Post)<-[:LIKED]-(l:User)
WITH u, posts, COUNT(DISTINCT l) AS likes_recebidos

OPTIONAL MATCH (u)-[:POSTED]->(p3:Post)<-[:COMMENTED]-(c:User)
WITH u, posts, likes_recebidos, COUNT(DISTINCT c) AS comments_recebidos

OPTIONAL MATCH (u)-[out:FOLLOWS]->()
WITH u, posts, likes_recebidos, comments_recebidos,
     COUNT(out) AS out_degree

OPTIONAL MATCH (u)<-[in:FOLLOWS]-()
RETURN u.id AS user,
       COUNT(in) AS in_degree,
       out_degree,
       posts,
       likes_recebidos,
       comments_recebidos,
       (likes_recebidos + comments_recebidos) AS engagement_score
ORDER BY in_degree DESC, engagement_score DESC
LIMIT 10;

/* ====================================================== 
BLOCO 5 – CAMINHOS E RECOMENDAÇÃO
====================================================== */
/* ------------------------------------------------------
   5A – Caminho mínimo entre usuários
------------------------------------------------------ */

:param userA => 2000;
:param userB => 2006;

MATCH (a:User {id:$userA}), (b:User {id:$userB})
MATCH p = shortestPath((a)-[*..5]-(b))
RETURN [n IN nodes(p) | labels(n)[0] + ':' + n.id] AS caminho,
       length(p) AS passos;
/* ------------------------------------------------------
   5B – Recomendação de novos usuários
------------------------------------------------------ */

/* :param { me: 2000 } */

MATCH (me:User {id:$me})-[:FOLLOWS]->(:User)-[:FOLLOWS]->(rec:User)
WHERE NOT (me)-[:FOLLOWS]->(rec)
  AND me <> rec
RETURN rec.id AS recomendado,
       count(*) AS score
ORDER BY score DESC
LIMIT 5;
/* ------------------------------------------------------
   5C – Recomendação mútua (seguem-se mutuamente)
------------------------------------------------------ */

MATCH (a:User)-[:FOLLOWS]->(b:User)
WHERE (b)-[:FOLLOWS]->(a)
RETURN a.id AS userA,
       b.id AS userB
LIMIT 20;

/* ======================================================
BLOCO 6 – POPULARIDADE E ENGAJAMENTO
====================================================== */
/* ------------------------------------------------------
   6A – Post mais curtido nos últimos 30 dias (2023)
------------------------------------------------------ */

WITH datetime("2023-06-01T00:00:00") AS fakeNow
MATCH (p:Post)<-[:LIKED]-(u:User)
WHERE p.created_at >= fakeNow - duration('P30D')
RETURN p.id AS post,
       count(u) AS likes
ORDER BY likes DESC
LIMIT 1;

/* ------------------------------------------------------
   6B – Top 10 posts mais curtidos
------------------------------------------------------ */

MATCH (p:Post)<-[:LIKED]-(u:User)
RETURN p.id AS post,
       count(u) AS likes
ORDER BY likes DESC, post
LIMIT 10;

/* ------------------------------------------------------
   6C – Top 10 posts mais comentados
------------------------------------------------------ */

MATCH (p:Post)<-[:COMMENTED]-(u:User)
RETURN p.id AS post,
       count(u) AS comments
ORDER BY comments DESC, post
LIMIT 10;

/* ------------------------------------------------------
   6D – Top 10 tags mais usadas
------------------------------------------------------ */

MATCH (t:Tag)<-[:HAS_TAG]-(p:Post)
RETURN t.tag_name AS tag,
       count(p) AS uso
ORDER BY uso DESC, tag
LIMIT 10;
/* ------------------------------------------------------
   6E – Usuário com maior engajamento recebido
------------------------------------------------------ */

MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(p:Post)
WITH u, COUNT(DISTINCT p) AS posts

OPTIONAL MATCH (u)-[:POSTED]->(p2:Post)<-[:LIKED]-(l:User)
WITH u, posts, COUNT(DISTINCT l) AS likes_recebidos

OPTIONAL MATCH (u)-[:POSTED]->(p3:Post)<-[:COMMENTED]-(c:User)
WITH u, posts, likes_recebidos, COUNT(DISTINCT c) AS comments_recebidos

RETURN u.id AS usuario,
       posts,
       likes_recebidos,
       comments_recebidos,
       (likes_recebidos + comments_recebidos) AS engagement_score
ORDER BY engagement_score DESC
LIMIT 10;

/* ======================================================
BLOCO 7 – COMUNIDADES E CENTRALIDADE
======================================================  */
/* ------------------------------------------------------
   7A – Comunidades aproximadas
------------------------------------------------------ */

MATCH (u:User)-[:FOLLOWS]->(f:User)
WITH u, COLLECT(DISTINCT f.id) AS seguindo
RETURN u.id AS usuario,
       seguindo,
       SIZE(seguindo) AS tamanho_da_comunidade
ORDER BY tamanho_da_comunidade DESC
LIMIT 10;

/* ------------------------------------------------------
   7B – Degree Centrality
------------------------------------------------------ */

MATCH (u:User)
OPTIONAL MATCH (u)-[out:FOLLOWS]->()
WITH u, COUNT(out) AS out_degree
OPTIONAL MATCH (u)<-[in:FOLLOWS]-()
RETURN u.id AS usuario,
       out_degree,
       COUNT(in) AS in_degree,
       (out_degree + COUNT(in)) AS grau_total
ORDER BY in_degree DESC
LIMIT 10;

/* ------------------------------------------------------
   7C – Engajamento + Centralidade
------------------------------------------------------ */

MATCH (u:User)
OPTIONAL MATCH (u)-[:POSTED]->(p:Post)
WITH u, COUNT(DISTINCT p) AS posts

OPTIONAL MATCH (u)-[:POSTED]->(p2:Post)<-[:LIKED]-(l:User)
WITH u, posts, COUNT(DISTINCT l) AS likes_recebidos

OPTIONAL MATCH (u)-[:POSTED]->(p3:Post)<-[:COMMENTED]-(c:User)
WITH u, posts, likes_recebidos, COUNT(DISTINCT c) AS comments_recebidos

OPTIONAL MATCH (u)-[out:FOLLOWS]->()
WITH u, posts, likes_recebidos, comments_recebidos,
     COUNT(out) AS out_degree

OPTIONAL MATCH (u)<-[in:FOLLOWS]-()
RETURN u.id AS usuario,
       posts,
       likes_recebidos,
       comments_recebidos,
       COUNT(in) AS in_degree,
       out_degree,
       (likes_recebidos + comments_recebidos) AS engagement_score
ORDER BY engagement_score DESC, in_degree DESC
LIMIT 10;

/* ------------------------------------------------------
   7D – Caminho entre usuários
------------------------------------------------------ */

/* :param { userA: 1, userB: 50 } */

MATCH (a:User {id:$userA}), (b:User {id:$userB})
MATCH path = shortestPath((a)-[*..5]-(b))
RETURN [n IN nodes(path) | labels(n)[0] + ':' + n.id] AS caminho,
       length(path) AS passos;
