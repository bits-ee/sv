def __debug(msg)
  logger.error("\n\e[1;31mdebug: #{msg}\e[0m\n\n") if Rails.env == 'development'
end