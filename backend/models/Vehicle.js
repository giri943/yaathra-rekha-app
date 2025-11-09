const mongoose = require('mongoose');

const vehicleSchema = new mongoose.Schema({
  model: {
    type: String,
    required: true,
    trim: true
  },
  manufacturer: {
    type: String,
    required: true,
    trim: true
  },
  insuranceExpiry: {
    type: Date,
    required: true
  },
  taxDate: {
    type: Date,
    required: true
  },
  testDate: {
    type: Date,
    required: true
  },
  pollutionDate: {
    type: Date,
    required: true
  },
  userId: {
    type: String,
    required: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Vehicle', vehicleSchema);