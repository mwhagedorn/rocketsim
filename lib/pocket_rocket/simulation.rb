require_relative "repository"
require "formatador"

require "interpolate"

module PocketRocket
  class Simulation

    VALID_KEYS = [
      :time_stamp,
      :altitude,
      :velocity,
      :accelleration,
      :max_acceleration,
      :weight,
      :total_mass,
      :time_step,
      :max_velocity,
      :current_velocity,
      :rocket,
      :motor,
      :motor_force
    ]

    attr_accessor(*VALID_KEYS)

    def initialize(options={})

      @repository           = Repository.new
      self.time_stamp       = 0
      self.current_velocity = 0
      self.altitude         = 0
    end

    def execute(rocket_name, engine_code)

      @motor        = get_motor(engine_code)
      @rocket       = get_rocket(rocket_name)
      rocket.engine = @motor
      @data         = []

      self.time_stamp       = 0
      self.current_velocity = 0.0
      self.max_velocity     = 0
      self.max_acceleration = 0
      self.altitude         = 0
      self.time_step        = 0.05
      self.velocity         = 0
      self.total_mass       = rocket.effective_mass(self.time_stamp)
      self.motor_force      = 0
      log
      velocity_at_instant(rocket, motor)

      while self.current_velocity > 0 || @data.count < 10
        velocity_at_instant(rocket, motor)
      end

      Formatador.display_table(@data, [:time_stamp, :altitude, :velocity, :acceleration, :motor_force, :mass])


      optimum_delay = coast_to_apogee_time


      @summary_data = [{:apogee        => self.apogee.round, :max_v => self.max_velocity.round,
                        :max_a         => self.max_acceleration.round, :burn_time => self.burn_time,
                        :coast_time    => self.coast_to_apogee_time.round(2),
                        :eject_time    => self.apogee_to_eject_time.round(2),
                        :optimum_delay => optimum_delay.round,
                        :launch_rod    => velocity_at_end_of_launch_rod.round,
                        :max_safe_wind => (velocity_at_end_of_launch_rod/5.0).round}]

      Formatador.display_table(@summary_data, [:apogee, :max_v, :burn_time, :max_a, :coast_time, :eject_time, :optimum_delay, :launch_rod, :max_safe_wind])


      puts "english units"

      @summary_data = [{:apogee        => (self.apogee*3.28).round, :max_v => (self.max_velocity*3.28).round,
                        :max_a         => (self.max_acceleration).round, :burn_time => self.burn_time,
                        :coast_time    => self.coast_to_apogee_time.round(2),
                        :eject_time    => self.apogee_to_eject_time.round(2),
                        :optimum_delay => optimum_delay.round,
                        :launch_rod    => (velocity_at_end_of_launch_rod*3.28).round,
                        :max_safe_wind => (velocity_at_end_of_launch_rod*3.28/5.0).round}]

      Formatador.display_table(@summary_data, [:apogee, :max_v, :burn_time, :max_a, :coast_time, :eject_time, :optimum_delay, :launch_rod, :max_safe_wind])

    end

    def apogee
      @data.last[:altitude]
    end

    def burn_time
      @motor.burn_time
    end

    def coast_to_apogee_time
      @data.last[:time_stamp] - burn_time
    end

    def apogee_to_eject_time
      #hack assumes 3 sec delay
      #@motor.delay - coast_to_apogee_time
      3 - coast_to_apogee_time
    end

    def velocity_at_end_of_launch_rod
      #== velocity at .9 meters
      vdata              = velocity_curve
      hdata              = altitude_curve
      time_at_end_of_rod = Interpolate::Points.new(transpose(hdata)).at(0.9)
      Interpolate::Points.new(vdata).at(time_at_end_of_rod)
    end

    def velocity_at_instant(rocket, motor)
      self.motor_force = motor.force_value_at(self.time_stamp)
      self.total_mass  = rocket.effective_mass(self.time_stamp)
      self.time_stamp  += time_step

      self.altitude, self.current_velocity, self.accelleration = rk4(self.current_velocity, self.altitude, time_step)

      if self.current_velocity < 0
        interpolate_apogee_value
      end
      log
      check_max_velocity(current_velocity)
      check_max_accell(accelleration)
    end

    def interpolate_apogee_value
      vel_distance          = @data.last[:velocity] + -1*self.current_velocity
      pct                   = (1.0 - -1*self.current_velocity/vel_distance)
      alt_distance          = self.altitude - @data.last[:altitude]
      new_altitude          = alt_distance*pct + @data.last[:altitude]
      self.altitude         = new_altitude
      self.current_velocity = 0
    end

    def altitude_curve
      curve_for(:altitude)
    end

    def velocity_curve
      curve_for(:velocity)
    end

    def velocity_vs_altitude_curve
      curve_for(:velocity)
    end

    def accelleration_curve
      curve_for(:accelleration)
    end

    def curve_for(item)
      vc = []
      @data.each do |data_point|
        vc << [data_point[:time_stamp], data_point[item]]
      end
      Hash[*vc.flatten]
    end

    def transpose(list)
      transposed = {}
      list.each do |point|
        transposed[point[1]] =point[0]
      end
      transposed
    end

    def rk4(velocity, altitude, dt)
      k1             = dt*altitude_derivative_at_n(velocity)
      l1             = dt*velocity_derivative_at_n(velocity, rocket)
      k2             = dt*altitude_derivative_at_n(velocity+l1/2.0)
      l2             = dt*velocity_derivative_at_n(velocity+l1/2.0, rocket)
      k3             = dt*altitude_derivative_at_n(velocity+l2/2.0)
      l3             = dt*velocity_derivative_at_n(velocity+l2/2.0, rocket)
      k4             = dt*altitude_derivative_at_n(velocity+l3)
      l4             = dt*velocity_derivative_at_n(velocity+l3, rocket)
      altitude_n     = altitude+1.0/6.0*(k1+2.00*k2+2.00*k3+k4)
      velocity_n     = velocity+1.0/6.0*(l1+2.00*l2+2.00*l3+l4)
      acceleration_n = velocity_derivative_at_n(velocity_n, rocket)/9.8
      [altitude_n, velocity_n, acceleration_n]
    end

    def velocity_derivative_at_n(velocity, rocket)
      gravity    = 9.81001
      pi         = 3.14159
      rho        = 1.2062
      area       = pi*(rocket.max_body_tube_diameter_mm/2*0.001)**2
      drag_force = 0.5*rho*rocket.drag_coefficient*area*(velocity**2)
      (self.motor_force-self.total_mass*gravity-drag_force)/self.total_mass
    end

    def altitude_derivative_at_n(velocity)
      velocity
    end

    def check_max_velocity(current_velocity)
      if current_velocity > self.max_velocity
        self.max_velocity = current_velocity
      end
    end

    def check_max_accell(current_accell)
      if current_accell > self.max_acceleration
        self.max_acceleration = current_accell
      end
    end

    def get_rocket(name)
      @repository.find_rocket_by_name(name)

    end

    def get_motor(code)
      @repository.find_engine_by_code(code)
    end

    def log
      @data << {:time_stamp => time_stamp, :motor_force => motor_force, :altitude => altitude, :velocity => current_velocity, :mass => total_mass, :acceleration => accelleration}
    end

  end
end



