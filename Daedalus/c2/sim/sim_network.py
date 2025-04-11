import numpy as np
from time import sleep
import tensorflow as tf
from tensorflow.keras import layers, models, optimizers

class Network:
    def __init__(self):
        # Initial simulated states of the nodes
        self.nodes = { 
            0: {"value": 10, "cowrie": False, "fake_edge_deployed": False, "fake_data": False, "attacker_active": False},
            1: {"value": 10, "cowrie": False, "fake_edge_deployed": False, "fake_data": False, "attacker_active": False},
            2: {"value": 10, "cowrie": False, "fake_edge_deployed": False, "fake_data": False, "attacker_active": False},
            3: {"value": 10, "cowrie": False, "fake_edge_deployed": False, "fake_data": False, "attacker_active": False},
            4: {"value": 10, "cowrie": False, "fake_edge_deployed": False, "fake_data": False, "attacker_active": False},
            5: {"value": 10, "cowrie": False, "fake_edge_deployed": False, "fake_data": False, "attacker_active": False},
            6: {"value": 10, "cowrie": False, "fake_edge_deployed": False, "fake_data": False, "attacker_active": False},
            7: {"value": 10, "cowrie": False, "fake_edge_deployed": False, "fake_data": False, "attacker_active": False}     
        }
    
    def observeNode(self, node):
        return self.nodes[node]

    def observeNetwork(self):
        return self.nodes

    def addFakeEdge(self, node):
        self.nodes[node]["fake_edge_deployed"] = True
        self.nodes[node]["attacker_active"] = False

    def removeFakeEdge(self, node):
        self.nodes[node]["fake_edge_deployed"] = False

    def addFakeNode(self, node):
        self.nodes[node]["cowrie"] = True
        self.nodes[node]["attacker_active"] = False

    def removeFakeNode(self, node):
        self.nodes[node]["cowrie"] = False

    def addFakeData(self, node):
        self.nodes[node]["fake_data"] = True
        self.nodes[node]["attacker_active"] = False

    def removeFakeData(self, node):
        self.nodes[node]["fake_data"] = False

    def simulate_attacker_activity(self):
        # Randomly simulate attacker activity on nodes
        for node in self.nodes:
            self.nodes[node]["attacker_active"] = np.random.rand() < 0.3  # 30% chance of attack

class DefenderPolicy(tf.keras.Model):
    def __init__(self):
        super(DefenderPolicy, self).__init__()
        self.network = Network()
        self.lstm_state = None
        self.observation_sequence = []

        num_hosts = len(self.network.nodes)
        observation_shape = (num_hosts * 1) + (num_hosts * 1) + (num_hosts * 1) + (num_hosts * 1) + (num_hosts * 1)
        self.lstm_units = 32

        self.lstm = layers.LSTM(self.lstm_units, return_state=True)
        self.host_selection_network = self.create_host_selection_network(num_hosts, self.lstm_units)
        self.action_selection_network = self.create_action_selection_network(self.lstm_units + num_hosts)

    def create_host_selection_network(self, num_hosts, input_shape):
        model = models.Sequential()
        model.add(layers.Dense(64, activation='relu', input_shape=(input_shape,)))
        model.add(layers.Dense(32, activation='relu'))
        model.add(layers.Dense(num_hosts, activation='softmax'))
        return model

    def create_action_selection_network(self, input_shape):
        model = models.Sequential()
        model.add(layers.Dense(64, activation='relu', input_shape=(input_shape,)))
        model.add(layers.Dense(32, activation='relu'))
        model.add(layers.Dense(7, activation='softmax'))
        return model

    def call(self, inputs, training=False):
        lstm_output, state_h, state_c = self.lstm(inputs)
        host_selection_output = self.host_selection_network(lstm_output)

        host_selection_sample = tf.random.categorical(tf.math.log(host_selection_output), 1)
        host_selection_sample = tf.squeeze(tf.one_hot(host_selection_sample, host_selection_output.shape[-1]), axis=1)
        
        action_inputs = tf.concat([lstm_output, host_selection_sample], axis=-1)
        action_selection_output = self.action_selection_network(action_inputs)
        
        return host_selection_output, host_selection_sample, action_selection_output, [state_h, state_c]

    def get_vector(self):
        self.network.simulate_attacker_activity()
        return self.network.observeNetwork(), any(node["attacker_active"] for node in self.network.observeNetwork().values())

    def flatten_observation(self, obs):
        flattened = np.concatenate([
            np.array([node["value"] for node in obs.values()]),
            np.array([node["cowrie"] for node in obs.values()]),
            np.array([node["fake_edge_deployed"] for node in obs.values()]),
            np.array([node["fake_data"] for node in obs.values()]),
            np.array([node["attacker_active"] for node in obs.values()])
        ])
        return flattened

    def execute(self, node, action):
        try:
            if action == 0 and not self.network.nodes[node]["cowrie"]:
                self.network.addFakeNode(node)
                print(f"Simulated: added fake node on machine {node}")
            elif action == 1 and not self.network.nodes[node]["fake_edge_deployed"]:
                self.network.addFakeEdge(node)
                print(f"Simulated: added fake edge on machine {node}")
            elif action == 2 and not self.network.nodes[node]["fake_data"]:
                self.network.addFakeData(node)
                print(f"Simulated: added fake data on machine {node}")
            elif action == 3 and self.network.nodes[node]["cowrie"]:
                self.network.removeFakeNode(node)
                print(f"Simulated: removed fake node on machine {node}")
            elif action == 4 and self.network.nodes[node]["fake_edge_deployed"]:
                self.network.removeFakeEdge(node)
                print(f"Simulated: removed fake edge on machine {node}")
            elif action == 5 and self.network.nodes[node]["fake_data"]:
                self.network.removeFakeData(node)
                print(f"Simulated: removed fake data on machine {node}")
            elif action == 6:
                print("Simulated: do nothing")
        except KeyError:
            print("Simulated: no attacker activity")

    def choose_action(self, current_observation):
        flattened_vector = self.flatten_observation(current_observation).reshape((1, -1))
        if len(self.observation_sequence) > 0:
            input_sequence = np.array(self.observation_sequence).reshape(1, len(self.observation_sequence), -1)
            embedded_vector = np.concatenate((input_sequence, flattened_vector[np.newaxis, :]), axis=1)
        else:
            embedded_vector = flattened_vector[np.newaxis, :]

        host_probs, host_selection_sample, action_probs, new_lstm_state = self.call(embedded_vector)

        self.lstm_state = new_lstm_state
        action_probs = action_probs.numpy().flatten()
        host_selection_sample = host_selection_sample.numpy().flatten()
        chosen_host = np.argmax(host_selection_sample)
        action_mask = self.create_action_mask(chosen_host)
        masked_action_probs = action_probs * action_mask

        if masked_action_probs.sum() == 0:
            print("all actions are masked out, defaulting to 'do nothing'.")
            masked_action_probs = action_mask

        masked_action_probs /= masked_action_probs.sum()
        chosen_action = np.random.choice(len(masked_action_probs), p=masked_action_probs)
        
        print(f"chosen host: {chosen_host}, chosen action: {chosen_action}")
        self.execute(chosen_host, chosen_action)
        self.update_observation_sequence(current_observation)

    def update_observation_sequence(self, observation_vector):
        flattened_vector = self.flatten_observation(observation_vector)
        self.observation_sequence.append(flattened_vector)
        if len(self.observation_sequence) > 10:
            self.observation_sequence.pop(0)
    
    def create_action_mask(self, node):
        state = self.network.nodes[node]
        action_mask = [1] * 7
        
        if state["cowrie"]:
            action_mask[0] = 0
        if state["fake_edge_deployed"]:
            action_mask[1] = 0
        if state["fake_data"]:
            action_mask[2] = 0
        if not state["cowrie"]:
            action_mask[3] = 0
        if not state["fake_edge_deployed"]:
            action_mask[4] = 0
        if not state["fake_data"]:
            action_mask[5] = 0

        return np.array(action_mask)
    
    def run(self):
        self.trigger = False
        while True:
            self.consecutive_attacker_absence = 0
            observation_vector, empty_bool = self.get_vector()
            if True in empty_bool:
                self.consecutive_attacker_absence = 0
                self.trigger = True
            else:
                self.consecutive_attacker_absence += 1
                print(f"no attacker activity, consecutive attacker absences: {self.consecutive_attacker_absence}")
                if self.consecutive_attacker_absence >= 10:
                    self.trigger = False
                else:
                    self.trigger = True
            if self.trigger == True:          
                print(f"current observation vector: {observation_vector}")
                self.choose_action(observation_vector)
            else:
                print("RL policy network off, 10 or more consecutive empty vectors")
            sleep(5)

