$: << File.expand_path(File.dirname(__FILE__) + "/../lib")
require 'passwords'
require 'rubygems'
require 'jabber/bot'

@hang = false

bot = Jabber::Bot.new(
  :name      => 'god test jabber bot',
  :jabber_id => 'bot@jnewland.com',
  :password  => PASSWORDS['bot@jnewland.com'],
  :is_public => true,
  :master    => 'jnewland@gmail.com'
)

bot.add_command(
  :syntax      => 'rand',
  :description => 'Produce a random number from 0 to 10',
  :regex       => /^rand$/,
  :is_public   => true
) do
  rand(10).to_s unless @hang
end

bot.add_command(
  :syntax      => 'ping',
  :description => 'Check to ensure the bot is not hung',
  :regex       => /^ping$/,
  :is_public => true
) do
  'pong' unless @hang
end

bot.add_command(
  :syntax      => 'hang',
  :description => 'tell the bot to hang',
  :regex       => /^hang$/
) do
  @hang = true
  'bot is hung, and will not respond to future calls to "ping" or "rand"'
end

bot.connect