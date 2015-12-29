require_relative "repository"
require "formatador"

require "interpolate"

module PocketRocket
  class Simulation

    RHO = 1.2505
    PI = Math::PI
    GRAV = 9.80665

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
      :motor_force,
      :drag_constant,
      :rho,
      :pi,
      :grav,
      :descent_rate,
      :descent_time,
      :wind_speed
    ]

    attr_accessor(*VALID_KEYS)

    def initialize(options={})

      @repository           = Repository.new
      self.time_stamp       = 0
      self.current_velocity = 0
      self.altitude         = 0
      self.rho = RHO
      self.pi = PI
      self.grav = GRAV
    end

    def execute(rocket_name, engine_code, angle=0.0, wind_speed=0.0, mass_override=0.0, chute_override=0.0)

      @motor        = get_motor(engine_code)
      @rocket       = get_rocket(rocket_name)
      @rocket.engine = @motor
      if mass_override
        @rocket.mass_override = mass_override
      end
      @data         = []

      self.time_stamp       = 0
      self.current_velocity = 0.0
      self.max_velocity     = 0
      self.max_acceleration = 0
      self.altitude         = 0
      self.time_step        = 0.005
      self.velocity         = 0
      self.total_mass       = @rocket.effective_mass(self.time_stamp)
      self.motor_force      = 0
      area = self.cross_sectional_area(@rocket.max_body_tube_diameter_mm)
      self.drag_constant =  (self.rho*@rocket.drag_coefficient*area)/2
      self.descent_time = 0.0
      self.descent_rate = 0.0
      self.wind_speed = wind_speed
      log
      velocity_at_instant(rocket, motor, angle.to_f)
      base_angle = angle.to_f
      while self.current_velocity > 0 || self.time_stamp < burn_time
        # 1m == ~3ft == launch rod length
        if self.altitude > 1
          angle = base_angle - self.weathercock_angle(wind_speed.to_f,self.current_velocity.to_f)
        end
        velocity_at_instant(rocket, motor,angle.to_f )
      end

      # calculate descent rate
      if @rocket.parachute_diameter_cm
        if @rocket.parachute_shape
          numerator = 2 * self.grav * self.total_mass
          diameter = @rocket.parachute_diameter_cm
          if chute_override > 0.0
            diameter = chute_override
          end
          denominator = self.parachute_area(diameter,@rocket.parachute_shape) * self.rho * 0.75
          v = Math.sqrt( numerator / denominator )
          self.descent_time = self.apogee/v
          self.descent_rate = v
        end

      end

      Formatador.display_table(@data, [:time_stamp, :altitude, :velocity, :acceleration, :motor_force, :mass])


      optimum_delay = coast_to_apogee_time

      safe_descent = 3.5..4.5
      if safe_descent.include?(self.descent_rate)
        descent_display = "[green]#{(self.descent_rate).round(2)}"
      else
        descent_display = "[red]#{(self.descent_rate).round(2)}"
      end

      if velocity_at_end_of_launch_rod.round >= 13
        vlr_display = "[green]#{(self.velocity_at_end_of_launch_rod).round(2)}"
      else
        vlr_display = "[red]#{(self.velocity_at_end_of_launch_rod).round(2)}"
      end

      puts "Liftoff Mass"
      puts @rocket.effective_mass(0.0)

      @summary_data = [{:apogee        => self.apogee.round(2), :max_v => self.max_velocity.round(2),
                        :max_a         => self.max_acceleration.round(2),
                        :ave_a => self.ave_accell.round(2),
                        :burn_time => self.burn_time,
                        :burn_alt => self.burn_alt.round(2),
                        :coast_time    => self.coast_to_apogee_time.round(2),
                        :eject_time    => self.apogee_to_eject_time.round(2),
                        :optimum_delay => optimum_delay.round,
                        :launch_rod    => vlr_display,
                        :max_safe_wind => (velocity_at_end_of_launch_rod/5.0).round,
                        :descent_rate => descent_display,
                        :descent_time => "[green]#{self.descent_time.round(2)}",
                        :total_time => self.burn_time.round(2) + self.coast_to_apogee_time.round(2) + self.descent_time.round(2)
                       }]

      Formatador.display_table(@summary_data, [:apogee, :max_v, :burn_time,:burn_alt,:max_a, :ave_a, :coast_time, :eject_time, :optimum_delay, :launch_rod, :max_safe_wind, :descent_rate, :descent_time, :total_time])

      puts "Descent Mass"
      puts @rocket.effective_mass(self.time_stamp)

      puts "english units"

      safe_descent = 11.5..14.8
      if safe_descent.include?(self.descent_rate*3.28)
        descent_display = "[green]#{(self.descent_rate*3.28).round(2)}"
      else
        descent_display = "[red]#{(self.descent_rate*3.28).round(2)}"
      end

      # m/s to mph
      if (velocity_at_end_of_launch_rod*2.23).round >= 30
        #mph
        vlr_display = "[green]#{(self.velocity_at_end_of_launch_rod*2.23).round(2)}"
      else
        vlr_display = "[red]#{(self.velocity_at_end_of_launch_rod*2.23).round(2)}"
      end

      puts "Liftoff Mass"
      puts @rocket.effective_mass(0.0)


      @summary_data = [{:apogee => (self.apogee*3.28).round(2),
                        #mph
                        :max_v => (self.max_velocity*2.23).round(2),
                        :max_a => (self.max_acceleration).round(2),
                        :ave_a => self.ave_accell.round(2),
                        :burn_time => self.burn_time,
                        :burn_alt => (self.burn_alt*3.28).round(2),
                        :coast_time    => self.coast_to_apogee_time.round(2),
                        :eject_time    => self.apogee_to_eject_time.round(2),
                        :optimum_delay => optimum_delay.round,
                        :launch_rod    => vlr_display,
                        :max_safe_wind => (velocity_at_end_of_launch_rod*2.23/5.0).round,
                        :descent_rate => descent_display,
                        :descent_time => "[green]#{self.descent_time.round(2)}",
                        :total_time => (self.burn_time + self.coast_to_apogee_time + self.descent_time.round(2)).round(2)}]
      puts("** ascent **")
      Formatador.display_table(@summary_data, [:apogee, :max_v, :burn_time, :burn_alt, :max_a, :ave_a, :coast_time, :eject_time, :optimum_delay, :launch_rod, :max_safe_wind, :descent_rate, :descent_time, :total_time])
      puts("** descent **")

      puts "Descent Mass"
      puts @rocket.effective_mass(self.time_stamp)

      @summary_data = [{:descent_rate => mps_to_fps(self.descent_rate).round(2),
                        :descent_time => self.descent_time.round(2),
                        :drift_2mph => m_to_ft(self.drift_distance_at(mph_to_mps(2))).round(2),
                        :drift_at3mph => m_to_ft(self.drift_distance_at(mph_to_mps(3))).round(2),
                        :drift_at4mph => m_to_ft(self.drift_distance_at(mph_to_mps(4))).round(2),
                        :drift_at5mph => m_to_ft(self.drift_distance_at(mph_to_mps(5))).round(2)}]
      Formatador.display_table(@summary_data, [:descent_rate, :drift_2mph, :drift_at3mph, :drift_at4mph, :drift_at5mph])

    end

    def parachute_area(diameter_cm, shape="hexagon")
      diameter_m = diameter_cm * 0.01
      if shape == "square"
        return diameter_m**2.0
      end
      if shape == "hexagon"
        return 0.866 * diameter_m**2.0
      end
      if shape == "octagon"
        return 0.828 * diameter_m**2.0
      end
      if shape == "circle"
        return Math::PI/4*diameter_m**2.0
      end
    end

    def recommended_parachute_cm(mass_g)
        if mass_g >= 300
          return 84
        end
        if mass_g >= 200
          return 69
        end
        if mass_g >= 150
          return 59
        end
        if mass_g >= 100
          return 48
        end

        if mass_g >= 80
          return 43
        end

        if mass_g >= 40
          return 31
        end

        if mass_g >= 20
          return 22
        end

        return 0
    end

    def drift_distance(descent_time)
      # x sec * w m/sec
      return self.wind_speed * descent_time
    end

    def drift_distance_at(wind_speed_m)
      # return meters
      return self.descent_time * wind_speed_m
    end

    def apogee
      @data.last[:altitude]
    end

    def burn_time
      @motor.burn_time
    end

    def burn_alt
      hdata              = altitude_curve
      alt = Interpolate::Points.new(hdata).at(burn_time)
    end

    def coast_to_apogee_time
      @data.last[:time_stamp] - burn_time
    end

    def apogee_to_eject_time
      #hack assumes 3 sec delay
      #TODO calc range.. i.e. 3-5
      #@motor.delay - coast_to_apogee_time

      3 - coast_to_apogee_time
    end

    def velocity_at_end_of_launch_rod
      # == velocity at .9 meters
      # > 13 m/s for safety, 30 mph
      # NAR  launchsafe - 4 times the velocity at which the wind is blowing
      vdata              = velocity_curve
      hdata              = altitude_curve
      time_at_end_of_rod = Interpolate::Points.new(transpose(hdata)).at(0.9)
      Interpolate::Points.new(vdata).at(time_at_end_of_rod)
    end

    def max_safe_wind
      # NAR  launchsafe - 4 times the velocity at which the wind is blowing
      (velocity_at_end_of_launch_rod/4.0).round
    end

    def velocity_at_instant(rocket, motor, angle=0.0)
      self.motor_force = motor.force_value_at(self.time_stamp)
      self.total_mass  = rocket.effective_mass(self.time_stamp)
      self.time_stamp  += time_step

      memo_velocity = self.current_velocity
      self.altitude, self.current_velocity = rk4(self.current_velocity, self.altitude, time_step, angle)

      self.accelleration = (self.current_velocity - memo_velocity)/self.time_step * 0.101971621

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
      curve_for(:acceleration)
    end

    def ave_accell
      data = accelleration_curve.collect{|item| item[1]}
      data.delete_if {|x| x == nil}
      data.delete_if {|x| x < 0 }
      data.inject(0.0){ |sum, el| sum + el }/ data.size
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

    def rk4(velocity, altitude, dt, angle = 0)
      k1             = dt*altitude_derivative_at_n(velocity)
      l1             = dt*velocity_derivative_at_n(velocity, rocket, angle)
      k2             = dt*altitude_derivative_at_n(velocity+l1/2.0)
      l2             = dt*velocity_derivative_at_n(velocity+l1/2.0, rocket, angle)
      k3             = dt*altitude_derivative_at_n(velocity+l2/2.0)
      l3             = dt*velocity_derivative_at_n(velocity+l2/2.0, rocket, angle)
      k4             = dt*altitude_derivative_at_n(velocity+l3)
      l4             = dt*velocity_derivative_at_n(velocity+l3, rocket, angle)
      altitude_n     = altitude+1.0/6.0*(k1+2.00*k2+2.00*k3+k4)
      velocity_n     = velocity+1.0/6.0*(l1+2.00*l2+2.00*l3+l4)
      [altitude_n, velocity_n]
    end

    def velocity_derivative_at_n(velocity, rocket, angle = 0.0)
      # vertical forces = (thrust(t) - drag(t))*sin(angle) - weight
      # a = f/m
      angle_rad = angle * Math::PI/180
      drag_force = self.drag_constant*(velocity**2)
      weight_force = self.total_mass*self.grav
      ((self.motor_force-drag_force)*Math::sin(angle_rad)-weight_force)/self.total_mass
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

    def weathercock_angle(wind_speed, relative_velocity)
    #  ---->  wind_speed m/sec
    #  \   |
    #   \  | relative wind m/sec
    #    \ |
    # ang  V
      if wind_speed == 0
        wind_speed = 0.01
      end
      90-(Math::atan(relative_velocity/wind_speed)*57.2958).to_f
    end

    def cross_sectional_area(diameter_mm)
      diameter_m = diameter_mm/1000.0
      PI*(diameter_m**2.0)/4
    end
  end
end


def mps_to_mph(meters_per_second)
  return meters_per_second * 2.237
end

def mps_to_fps(mps)
   mps_to_mph(mps) * 1.4667
end

def mph_to_mps(miles_per_hour)
  return miles_per_hour * 0.44704
end

def m_to_ft(meters)
  return meters * 3.281
end



