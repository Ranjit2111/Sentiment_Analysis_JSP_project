package com.globalcommunication.utils;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Provides sentiment analysis functionality for chat messages.
 * This is a simple rule-based sentiment analyzer that analyzes text
 * to determine if the overall sentiment is positive, negative, or neutral.
 */
public class SentimentAnalyzer {

    // Maps for positive and negative words
    private static final Map<String, Double> POSITIVE_WORDS = new HashMap<>();
    private static final Map<String, Double> NEGATIVE_WORDS = new HashMap<>();
    
    // Initialize the sentiment word lists with weights
    static {
        // Positive words
        POSITIVE_WORDS.put("good", 1.0);
        POSITIVE_WORDS.put("great", 1.5);
        POSITIVE_WORDS.put("excellent", 2.0);
        POSITIVE_WORDS.put("wonderful", 1.5);
        POSITIVE_WORDS.put("amazing", 1.5);
        POSITIVE_WORDS.put("happy", 1.0);
        POSITIVE_WORDS.put("love", 1.5);
        POSITIVE_WORDS.put("like", 0.8);
        POSITIVE_WORDS.put("best", 1.5);
        POSITIVE_WORDS.put("awesome", 1.5);
        POSITIVE_WORDS.put("fantastic", 1.5);
        POSITIVE_WORDS.put("perfect", 2.0);
        POSITIVE_WORDS.put("thank", 1.0);
        POSITIVE_WORDS.put("thanks", 1.0);
        POSITIVE_WORDS.put("cool", 0.8);
        POSITIVE_WORDS.put("nice", 0.8);
        POSITIVE_WORDS.put("enjoy", 1.0);
        POSITIVE_WORDS.put("excited", 1.2);
        POSITIVE_WORDS.put("glad", 1.0);
        POSITIVE_WORDS.put("helpful", 1.0);
        POSITIVE_WORDS.put("impressive", 1.2);
        POSITIVE_WORDS.put("positive", 1.0);
        POSITIVE_WORDS.put("success", 1.0);
        POSITIVE_WORDS.put("yay", 1.0);
        
        // Negative words
        NEGATIVE_WORDS.put("bad", -1.0);
        NEGATIVE_WORDS.put("terrible", -1.5);
        NEGATIVE_WORDS.put("awful", -1.5);
        NEGATIVE_WORDS.put("horrible", -1.8);
        NEGATIVE_WORDS.put("sad", -1.0);
        NEGATIVE_WORDS.put("hate", -1.5);
        NEGATIVE_WORDS.put("dislike", -0.8);
        NEGATIVE_WORDS.put("worst", -1.5);
        NEGATIVE_WORDS.put("annoying", -1.0);
        NEGATIVE_WORDS.put("disappointing", -1.2);
        NEGATIVE_WORDS.put("poor", -1.0);
        NEGATIVE_WORDS.put("sorry", -0.5);
        NEGATIVE_WORDS.put("fail", -1.0);
        NEGATIVE_WORDS.put("difficult", -0.7);
        NEGATIVE_WORDS.put("problem", -0.8);
        NEGATIVE_WORDS.put("issue", -0.7);
        NEGATIVE_WORDS.put("error", -0.8);
        NEGATIVE_WORDS.put("frustrated", -1.2);
        NEGATIVE_WORDS.put("upset", -1.0);
        NEGATIVE_WORDS.put("angry", -1.2);
        NEGATIVE_WORDS.put("stupid", -1.3);
        NEGATIVE_WORDS.put("useless", -1.3);
        NEGATIVE_WORDS.put("broken", -1.0);
        NEGATIVE_WORDS.put("negative", -1.0);
        NEGATIVE_WORDS.put("die", -2.0);
        NEGATIVE_WORDS.put("death", -2.0);
        NEGATIVE_WORDS.put("dead", -2.0);
        NEGATIVE_WORDS.put("kill", -2.0);
        NEGATIVE_WORDS.put("hurt", -1.5);
        NEGATIVE_WORDS.put("pain", -1.5);
        NEGATIVE_WORDS.put("crying", -1.2);
        NEGATIVE_WORDS.put("cry", -1.2);
        NEGATIVE_WORDS.put("depressed", -2.0);
        NEGATIVE_WORDS.put("depression", -2.0);
        NEGATIVE_WORDS.put("anxiety", -1.5);
        NEGATIVE_WORDS.put("anxious", -1.5);
        NEGATIVE_WORDS.put("worried", -1.0);
        NEGATIVE_WORDS.put("worry", -1.0);
        NEGATIVE_WORDS.put("scared", -1.5);
        NEGATIVE_WORDS.put("fear", -1.5);
        NEGATIVE_WORDS.put("alone", -1.0);
        NEGATIVE_WORDS.put("lonely", -1.2);
        NEGATIVE_WORDS.put("miserable", -1.5);
        NEGATIVE_WORDS.put("hopeless", -1.8);
        NEGATIVE_WORDS.put("helpless", -1.5);
    }
    
    // Negation words that can reverse sentiment
    private static final List<String> NEGATION_WORDS = Arrays.asList(
        "not", "don't", "doesn't", "didn't", "no", "never", "cannot", "can't", "won't", "wouldn't"
    );
    
    /**
     * Analyzes the sentiment of a given text message.
     * 
     * @param text The text to analyze
     * @return A SentimentResult object containing the sentiment score and category
     */
    public static SentimentResult analyzeSentiment(String text) {
        if (text == null || text.trim().isEmpty()) {
            return new SentimentResult(0, "NEUTRAL");
        }
        
        // Convert to lowercase and split into words
        String[] words = text.toLowerCase().replaceAll("[^a-zA-Z0-9\\s']", " ").split("\\s+");
        
        double score = 0;
        boolean foundNegation = false;
        
        // Process each word in the text
        for (int i = 0; i < words.length; i++) {
            String word = words[i];
            
            // Check if this is a negation word
            if (NEGATION_WORDS.contains(word)) {
                foundNegation = true;
                continue;
            }
            
            // Check for positive and negative words
            if (POSITIVE_WORDS.containsKey(word)) {
                double wordScore = POSITIVE_WORDS.get(word);
                score += foundNegation ? -wordScore : wordScore;
                foundNegation = false;  // Reset negation flag
            } else if (NEGATIVE_WORDS.containsKey(word)) {
                double wordScore = NEGATIVE_WORDS.get(word);
                score += foundNegation ? -wordScore : wordScore;
                foundNegation = false;  // Reset negation flag
            }
        }
        
        // Determine sentiment category based on score
        String category;
        if (score > 0.3) {  // Lower threshold for positive sentiment
            category = "POSITIVE";
        } else if (score < -0.3) {  // Lower threshold for negative sentiment
            category = "NEGATIVE";
        } else {
            category = "NEUTRAL";
        }
        
        return new SentimentResult(score, category);
    }
    
    /**
     * Returns a sentiment emoji based on the sentiment category.
     * 
     * @param category The sentiment category (POSITIVE, NEGATIVE, NEUTRAL)
     * @return An emoji representing the sentiment
     */
    public static String getSentimentEmoji(String category) {
        switch (category) {
            case "POSITIVE":
                return "😊"; // Happy face
            case "NEGATIVE":
                return "😔"; // Sad face
            case "NEUTRAL":
            default:
                return "😐"; // Neutral face
        }
    }
    
    /**
     * Inner class to represent the result of sentiment analysis.
     */
    public static class SentimentResult {
        private final double score;
        private final String category;
        
        public SentimentResult(double score, String category) {
            this.score = score;
            this.category = category;
        }
        
        public double getScore() {
            return score;
        }
        
        public String getCategory() {
            return category;
        }
        
        @Override
        public String toString() {
            return "Sentiment: " + category + " (Score: " + score + ")";
        }
    }
} 