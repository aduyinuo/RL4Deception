import gymnasium as gym
from gymnasium import spaces
import numpy as np
from sim_network import Network, DefenderPolicy

class NetworkDefenseEnv(gym.Env):
    def __init__(self):
        super(NetworkDefenseEnv, self).__init__()
        self.defender = DefenderPolicy()
        
        num_hosts = len(self.defender.network.nodes)
        observation_shape = (num_hosts * 1) + (num_hosts * 3) + (num_hosts * 1) + (num_hosts * 1) + (num_hosts * 1) + (num_hosts * 1)
        self.action_space = spaces.Discrete(7)
        self.observation_space = spaces.Box(low=0, high=1, shape=(observation_shape,), dtype=np.float32)

        self.initial_observation = self.defender.get_vector()
        self.current_observation = None

        metadata = {
            "render.modes": ["human"]
        }

        self.reset()

    def reset(self, seed=None, options=None):
        return self.initial_observation, {}
        # return self.defender.flatten_observation(self.initial_observation)

    def step(self, action):
        info = {}
        node = action // 7
        action_type = action % 7
        self.defender.execute(node, action_type)
        self.current_observation, attacker_active = self.defender.get_vector()
        reward = self.calculate_reward(attacker_active)
        done = False
        return self.defender.flatten_observation(self.current_observation), reward, done, info


    def calculate_reward(self, attacker_active):
        if True in attacker_active:
            return -1
        else:
            return 1


