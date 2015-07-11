module I3
  module Bar
    module BasicWidgets

      Hostname = {
        name: 'hostname',
        timeout: 100,
        options: {},
        proc: -> { [`whoami`, '@',  `hostname`].map(&:chomp).join}
      }

    end
  end
end