require 'httparty'
require 'json'

# Configurações básicas
ORGANIZATION = 'sua-organizacao'  # Substitua pelo nome da sua organização
REPO = 'seu-repositorio'          # Substitua pelo nome do seu repositório
ACCESS_TOKEN = 'seu-access-token' # Substitua pelo seu token de acesso do GitHub

# Endpoint da API para listar PRs
endpoint = "https://api.github.com/repos/#{ORGANIZATION}/#{REPO}/pulls"

# Parâmetros da requisição
params = {
  state: 'open',    # Somente PRs abertos
  sort: 'created',  # Ordenar por data de criação (ou outro critério que preferir)
  direction: 'desc',# Ordem descendente (do mais recente para o mais antigo)
  access_token: ACCESS_TOKEN  # Token de acesso para autenticação
}

# Faz a requisição GET para o endpoint
response = HTTParty.get(endpoint, query: params)

# Verifica se a requisição foi bem sucedida
if response.code == 200
  # Parseia a resposta JSON
  prs = JSON.parse(response.body)

  # Filtra os PRs que precisam de code review
  prs_needing_review = prs.select do |pr|
    pr['state'] == 'open' && pr['draft'] == false && pr['requested_reviewers'].empty?
  end

  # Imprime os títulos dos PRs que precisam de code review
  puts "Pull Requests que precisam de code review para serem mergeados:"
  prs_needing_review.each do |pr|
    puts "- #{pr['title']} (#{pr['html_url']})"
  end
else
  puts "Erro ao acessar a API do GitHub: #{response.code}, #{response.message}"
end
