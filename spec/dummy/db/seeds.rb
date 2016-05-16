MAX_USER = 1000000
QTD_RELATIONSHIPS = 400
QTD_EVENTS = 10

r = Random.new

(1..MAX_USER).each do |i|
  puts "#{i}"
  SocialFramework::User.create username: "user#{i}", email: "user#{i}@email.com", password: "12345678"
end
puts "Usuários Cadastrados"

(1..((MAX_USER/2)-1)).each do |i|
  puts "Usuário #{i}"
  u1 = SocialFramework::User.find i
  result = (i/QTD_RELATIONSHIPS)

  ((result*QTD_RELATIONSHIPS+MAX_USER/2)..(result*QTD_RELATIONSHIPS+(MAX_USER/2+QTD_RELATIONSHIPS))).each do |j|
    u2 = SocialFramework::User.find j
    u1.create_relationship u2, "friend", true, true
  end

  puts "arestas criados"

  (1..QTD_EVENTS).each do |k|
    result = nil

    while (result == nil)
      puts "evento #{k}"
      day = r.rand(1..28)
      month = r.rand(1..12)
      hour = r.rand(0..23)
      duration = r.rand(1..4)
      date = DateTime.new(2016, month, day, hour, 0, 0)

      result = u1.schedule.create_event "Evento #{k} do user#{i}", date, duration.hour
    end
  end
end
puts "Eventos e relacionamentos Cadastrados"

((MAX_USER/2)..MAX_USER).each do |i|
  puts "Usuário #{i}"
  u1 = SocialFramework::User.find i
  
  (1..QTD_EVENTS).each do |k|
    result = nil

    while result == nil
      id = r.rand(1..(((MAX_USER/2)-1)*QTD_EVENTS))
      e = SocialFramework::Event.find id
      result = u1.schedule.enter_in_event e
    end
  end
end
