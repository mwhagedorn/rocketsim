require_relative "repository"
require "formatador"

class Simulation

  VALID_KEYS = [
    :time_stamp,
    :altitude,
    :velocity,
    :accelleration,
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

    @repository = Repository.new
    self.time_stamp = 0
    self.current_velocity = 0
    self.altitude = 0
  end

  def execute(rocket_name, engine_code)

    @motor = get_motor(engine_code)
    @rocket = get_rocket(rocket_name)
    rocket.engine = @motor
    @data = []

    self.time_stamp = 0
    current_velocity = 0
    self.max_velocity = 0
    self.altitude = 0
    self.time_step = 0.05
    self.velocity = 0
    self.total_mass = rocket.effective_mass(self.time_stamp)
    self.motor_force = 0
   log
   velocity_at_instant(rocket,motor)

   while self.current_velocity > 0
     velocity_at_instant(rocket,motor)
   end

   Formatador.display_table(@data,[:time_stamp, :altitude, :velocity, :motor_force,:mass])

   coast_time = @data.last[:time_stamp] - @motor.burn_time

   optimum_delay = coast_time
   puts "Optimal delay = #{optimum_delay.round}"


  end

  def velocity_at_instant(rocket, motor)
    self.motor_force = motor.force_value_at(self.time_stamp)
    self.total_mass = rocket.effective_mass(self.time_stamp)
    self.time_stamp += time_step

    self.altitude, self.current_velocity = rk4(self.current_velocity, self.altitude, time_step)
    if self.current_velocity < 0
      vel_distance = @data.last[:velocity] + -1*self.current_velocity
      pct = (1.0 - -1*self.current_velocity/vel_distance)
      alt_distance = self.altitude - @data.last[:altitude]
      new_altitude = alt_distance*pct + @data.last[:altitude]
      puts "interpolated altitude #{new_altitude}"
      self.altitude = new_altitude
      self.current_velocity = 0
    end
    log
    check_max_velocity(current_velocity)
  end

  def rk4(velocity,altitude, dt)
    k1 = dt*altitude_derivative_at_n(velocity)
    l1 = dt*velocity_derivative_at_n(velocity,rocket)
    k2 = dt*altitude_derivative_at_n(velocity+l1/2.0)
    l2 = dt*velocity_derivative_at_n(velocity+l1/2.0,rocket)
    k3 = dt*altitude_derivative_at_n(velocity+l2/2.0)
    l3 = dt*velocity_derivative_at_n(velocity+l2/2.0,rocket)
    k4 = dt*altitude_derivative_at_n(velocity+l3)
    l4 = dt*velocity_derivative_at_n(velocity+l3,rocket)
    altitude_n = altitude+1.0/6.0*(k1+2.00*k2+2.00*k3+k4)
    velocity_n = velocity+1.00/6.00*(l1+2.00*l2+2.00*l3+l4)
    [altitude_n,velocity_n]
  end

  def velocity_derivative_at_n(velocity,rocket)
    gravity = 9.81001
    pi   = 3.14159
    rho  = 1.2062
    area = pi*(rocket.max_body_tube_diameter_mm/2*0.001)**2
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

  def get_rocket(name)
    @repository.find_rocket_by_name(name)

  end

  def get_motor(code)
    @repository.find_engine_by_code(code)
  end

  def log
    @data << {:time_stamp => time_stamp, :motor_force => motor_force, :altitude => altitude, :velocity => current_velocity, :mass => total_mass}
  end

end

sim = Simulation.new
sim.execute("alpha", "C6")


