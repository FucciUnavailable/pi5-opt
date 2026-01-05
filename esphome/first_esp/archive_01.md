# code for first ESP with OLED .96

`
esphome:
  name: temp-sensor-bedroom
  friendly_name: Living Room Display

esp32:
  board: esp32dev
  framework:
    type: arduino

logger:
api:
  encryption:
    key: !secret api_encryption_key

ota:
  - platform: esphome
    password: !secret ota_password

wifi:
  ssid: !secret wifi_ssid
  password: !secret wifi_password
  manual_ip:
    static_ip: 10.0.0.140
    gateway: 10.0.0.1
    subnet: 255.255.255.0
  ap:
    ssid: "Display Fallback"
    password: "fallback12345"

i2c:
  sda: GPIO21
  scl: GPIO22
  scan: true

time:
  - platform: homeassistant
    id: ha_time

# ========== MODE SELECTOR ==========
select:
  - platform: template
    name: "Display Mode"
    id: display_mode
    optimistic: true
    options:
      - "Clock + Temp"
      - "Clock"
      - "Weather"
      - "Game of Life"
      - "Random Facts"
      - "Jokes"
      - "Bouncing Ball"
      - "Matrix Rain"
      - "Scrolling Text"
    initial_option: "Clock + Temp"
    icon: "mdi:monitor-dashboard"

# ========== CUSTOM INPUTS ==========
text:
  - platform: template
    name: "Custom Fact 1"
    id: fact1
    optimistic: true
    initial_value: "Octopuses have 3 hearts!"
    mode: text
    
  - platform: template
    name: "Custom Fact 2"
    id: fact2
    optimistic: true
    initial_value: "Honey never spoils!"
    mode: text
    
  - platform: template
    name: "Custom Fact 3"
    id: fact3
    optimistic: true
    initial_value: "A day on Venus > its year!"
    mode: text

  - platform: template
    name: "Custom Joke 1"
    id: joke1
    optimistic: true
    initial_value: "Atoms make up everything!"
    mode: text
    
  - platform: template
    name: "Custom Joke 2"
    id: joke2
    optimistic: true
    initial_value: "Parallel lines never meet!"
    mode: text
    
  - platform: template
    name: "Scrolling Message"
    id: scroll_msg
    optimistic: true
    initial_value: "*** HELLO WORLD! *** ESPHOME ROCKS! ***"
    mode: text

# ========== WEATHER DATA ==========
sensor:
  - platform: homeassistant
    id: weather_temp
    entity_id: weather.forecast_home
    attribute: temperature
    
  - platform: homeassistant
    id: weather_humidity
    entity_id: weather.forecast_home
    attribute: humidity

  - platform: wifi_signal
    name: "WiFi Signal"
    id: wifi_strength
    update_interval: 60s
    
  - platform: uptime
    name: "Uptime"
    id: uptime_sec

text_sensor:
  - platform: homeassistant
    id: weather_condition
    entity_id: weather.forecast_home

# ========== ANIMATION GLOBALS ==========
globals:
  # Game of Life
  - id: game_grid
    type: bool[128]
    restore_value: no
    initial_value: '{false}'
    
  - id: game_generation
    type: int
    restore_value: no
    initial_value: '0'
    
  # General counters
  - id: fact_index
    type: int
    restore_value: no
    initial_value: '0'
    
  # Bouncing ball
  - id: ball_x
    type: int
    restore_value: no
    initial_value: '64'
    
  - id: ball_y
    type: int
    restore_value: no
    initial_value: '32'
    
  - id: ball_dx
    type: int
    restore_value: no
    initial_value: '2'
    
  - id: ball_dy
    type: int
    restore_value: no
    initial_value: '1'
    
  # Scrolling text
  - id: scroll_pos
    type: int
    restore_value: no
    initial_value: '128'

interval:
  # Game of Life - 500ms
  - interval: 500ms
    then:
      - lambda: |-
          if (id(display_mode).current_option() == "Game of Life") {
            bool new_grid[128];
            
            if (id(game_generation) == 0) {
              for (int i = 0; i < 128; i++) {
                id(game_grid)[i] = (rand() % 100) < 30;
              }
            }
            
            for (int y = 0; y < 8; y++) {
              for (int x = 0; x < 16; x++) {
                int idx = y * 16 + x;
                int neighbors = 0;
                
                for (int dy = -1; dy <= 1; dy++) {
                  for (int dx = -1; dx <= 1; dx++) {
                    if (dx == 0 && dy == 0) continue;
                    int ny = (y + dy + 8) % 8;
                    int nx = (x + dx + 16) % 16;
                    if (id(game_grid)[ny * 16 + nx]) neighbors++;
                  }
                }
                
                if (id(game_grid)[idx]) {
                  new_grid[idx] = (neighbors == 2 || neighbors == 3);
                } else {
                  new_grid[idx] = (neighbors == 3);
                }
              }
            }
            
            for (int i = 0; i < 128; i++) {
              id(game_grid)[i] = new_grid[i];
            }
            
            id(game_generation)++;
            if (id(game_generation) > 100) id(game_generation) = 0;
          }
  
  # Rotate facts every 10s
  - interval: 10s
    then:
      - lambda: |-
          id(fact_index) = (id(fact_index) + 1) % 3;
  
  # Bouncing ball - 50ms (smooth!)
  - interval: 50ms
    then:
      - lambda: |-
          if (id(display_mode).current_option() == "Bouncing Ball") {
            id(ball_x) += id(ball_dx);
            id(ball_y) += id(ball_dy);
            
            // Bounce off walls
            if (id(ball_x) <= 2 || id(ball_x) >= 126) id(ball_dx) = -id(ball_dx);
            if (id(ball_y) <= 2 || id(ball_y) >= 62) id(ball_dy) = -id(ball_dy);
          }
  
  # Scrolling text - 50ms
  - interval: 50ms
    then:
      - lambda: |-
          if (id(display_mode).current_option() == "Scrolling Text") {
            id(scroll_pos) -= 2;
            if (id(scroll_pos) < -500) id(scroll_pos) = 128;
          }

# ========== DISPLAY ==========
display:
  - platform: ssd1306_i2c
    model: "SSD1306 128x64"
    address: 0x3C
    update_interval: 50ms
    lambda: |-
      std::string mode = id(display_mode).current_option();
      
      // ===== CLOCK + TEMP COMBO =====
      if (mode == "Clock + Temp") {
        // Time at top
        it.strftime(64, 0, id(font_large), TextAlign::TOP_CENTER, 
                    "%H:%M", id(ha_time).now());
        
        // Temperature below
        if (id(weather_temp).has_state()) {
          it.printf(64, 28, id(font_huge), TextAlign::TOP_CENTER,
                    "%.0f°", id(weather_temp).state);
        } else {
          it.printf(64, 28, id(font_med), TextAlign::TOP_CENTER, "No Temp");
        }
        
        // Tiny date at bottom
        it.strftime(64, 55, id(font_tiny), TextAlign::TOP_CENTER,
                    "%a %b %d", id(ha_time).now());
      }
      
      // ===== CLOCK ONLY =====
      else if (mode == "Clock") {
        it.strftime(64, 10, id(font_huge), TextAlign::TOP_CENTER, 
                    "%H:%M", id(ha_time).now());
        it.strftime(64, 50, id(font_small), TextAlign::TOP_CENTER,
                    "%b %d", id(ha_time).now());
      }
      
      // ===== WEATHER =====
      else if (mode == "Weather") {
        if (id(weather_condition).has_state()) {
          it.printf(64, 2, id(font_med), TextAlign::TOP_CENTER, 
                    "%s", id(weather_condition).state.c_str());
        }
        
        if (id(weather_temp).has_state()) {
          it.printf(64, 20, id(font_huge), TextAlign::TOP_CENTER,
                    "%.0f°", id(weather_temp).state);
        }
        
        if (id(weather_humidity).has_state()) {
          it.printf(64, 52, id(font_small), TextAlign::TOP_CENTER,
                    "%.0f%%", id(weather_humidity).state);
        }
      }
      
      // ===== GAME OF LIFE =====
      else if (mode == "Game of Life") {
        for (int y = 0; y < 8; y++) {
          for (int x = 0; x < 16; x++) {
            if (id(game_grid)[y * 16 + x]) {
              it.filled_rectangle(x * 8, y * 8, 6, 6);
            }
          }
        }
      }
      
      // ===== BOUNCING BALL =====
      else if (mode == "Bouncing Ball") {
        // Draw border
        it.rectangle(0, 0, 128, 64);
        
        // Draw ball
        it.filled_circle(id(ball_x), id(ball_y), 4);
        
        // Score/counter at top
        it.printf(64, 2, id(font_tiny), TextAlign::TOP_CENTER, 
                  "Uptime: %ds", (int)id(uptime_sec).state);
      }
      
      // ===== MATRIX RAIN =====
      else if (mode == "Matrix Rain") {
        // Simple matrix effect without arrays
        static int drops[16] = {0};
        
        for (int col = 0; col < 16; col++) {
          drops[col] += 1;
          if (drops[col] > 8) {
            drops[col] = rand() % 2 == 0 ? 0 : -rand() % 3;
          }
          
          int drop_y = drops[col];
          
          // Draw falling characters
          for (int i = 0; i < 8; i++) {
            int y = (drop_y - i) * 8;
            if (y >= 0 && y < 64) {
              char c = 'A' + (rand() % 26);
              if (i == 0) {
                it.printf(col * 8, y, id(font_tiny), "%c", c);
              } else if (i < 3) {
                it.rectangle(col * 8, y, 1, 1);
              }
            }
          }
        }
      }
      
      // ===== SCROLLING TEXT =====
      else if (mode == "Scrolling Text") {
        std::string msg = id(scroll_msg).state;
        it.printf(id(scroll_pos), 20, id(font_large), "%s", msg.c_str());
      }
      
      // ===== FACTS =====
      else if (mode == "Random Facts") {
        it.printf(64, 0, id(font_small), TextAlign::TOP_CENTER, "FACT:");
        
        std::string fact;
        if (id(fact_index) == 0) fact = id(fact1).state;
        else if (id(fact_index) == 1) fact = id(fact2).state;
        else fact = id(fact3).state;
        
        it.printf(0, 14, id(font_small), "%s", fact.c_str());
      }
      
      // ===== JOKES =====
      else if (mode == "Jokes") {
        it.printf(64, 0, id(font_small), TextAlign::TOP_CENTER, "JOKE:");
        
        std::string joke;
        if (id(fact_index) % 2 == 0) joke = id(joke1).state;
        else joke = id(joke2).state;
        
        it.printf(0, 14, id(font_small), "%s", joke.c_str());
      }

font:
  - file: "gfonts://Roboto Mono"
    id: font_huge
    size: 28
    
  - file: "gfonts://Roboto"
    id: font_large
    size: 18
    
  - file: "gfonts://Roboto"
    id: font_med
    size: 13
    
  - file: "gfonts://Roboto"
    id: font_small
    size: 10
    
  - file: "gfonts://Roboto Mono"
    id: font_tiny
    size: 8

status_led:
  pin:
    number: GPIO2

`
