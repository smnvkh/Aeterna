json.extract! memory, :id, :title, :body, :date, :image_url

json.family_member memory.family_member.to_s

json.url api_v1_memory_url(memory, format: :json)
