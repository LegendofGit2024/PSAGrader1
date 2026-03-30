import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { StatusBar } from 'expo-status-bar';
import { View, Text, StyleSheet } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

import AnalyzeScreen from './screens/AnalyzeScreen';
import PortfolioScreen from './screens/PortfolioScreen';
import SettingsScreen from './screens/SettingsScreen';
import { COLORS } from './utils/theme';

const Tab = createBottomTabNavigator();

function TabIcon({ name, focused }) {
  const icons = { Analyze: '⚡', Portfolio: '📁', Settings: '⚙️' };
  return (
    <View style={[styles.tabIcon, focused && styles.tabIconActive]}>
      <Text style={styles.tabEmoji}>{icons[name]}</Text>
      <Text style={[styles.tabLabel, focused && styles.tabLabelActive]}>{name}</Text>
    </View>
  );
}

export default function App() {
  return (
    <GestureHandlerRootView style={{ flex: 1 }}>
      <SafeAreaProvider>
        <StatusBar style="light" />
        <NavigationContainer>
          <Tab.Navigator
            screenOptions={{
              headerShown: false,
              tabBarStyle: styles.tabBar,
              tabBarShowLabel: false,
            }}
          >
            <Tab.Screen
              name="Analyze"
              component={AnalyzeScreen}
              options={{ tabBarIcon: ({ focused }) => <TabIcon name="Analyze" focused={focused} /> }}
            />
            <Tab.Screen
              name="Portfolio"
              component={PortfolioScreen}
              options={{ tabBarIcon: ({ focused }) => <TabIcon name="Portfolio" focused={focused} /> }}
            />
            <Tab.Screen
              name="Settings"
              component={SettingsScreen}
              options={{ tabBarIcon: ({ focused }) => <TabIcon name="Settings" focused={focused} /> }}
            />
          </Tab.Navigator>
        </NavigationContainer>
      </SafeAreaProvider>
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: COLORS.surface,
    borderTopColor: COLORS.border,
    borderTopWidth: 1,
    height: 70,
    paddingBottom: 8,
  },
  tabIcon: { alignItems: 'center', paddingTop: 6 },
  tabIconActive: {},
  tabEmoji: { fontSize: 20 },
  tabLabel: { fontSize: 10, color: COLORS.muted, marginTop: 2 },
  tabLabelActive: { color: COLORS.accent },
});
