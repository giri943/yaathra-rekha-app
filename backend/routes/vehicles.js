const express = require('express');
const router = express.Router();
const Vehicle = require('../models/Vehicle');
const auth = require('../middleware/auth');

// Get all vehicles for authenticated user
router.get('/', auth, async (req, res) => {
  try {
    const vehicles = await Vehicle.find({ userId: req.user.id });
    res.json(vehicles);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Add new vehicle
router.post('/', auth, async (req, res) => {
  try {
    const { model, manufacturer, insuranceExpiry, taxDate, testDate, pollutionDate } = req.body;
    
    const vehicle = new Vehicle({
      model,
      manufacturer,
      insuranceExpiry,
      taxDate,
      testDate,
      pollutionDate,
      userId: req.user.id
    });

    await vehicle.save();
    res.status(201).json(vehicle);
  } catch (error) {
    res.status(400).json({ message: 'Error creating vehicle', error: error.message });
  }
});

// Update vehicle
router.put('/:id', auth, async (req, res) => {
  try {
    const { model, manufacturer, insuranceExpiry, taxDate, testDate, pollutionDate } = req.body;
    
    const vehicle = await Vehicle.findOneAndUpdate(
      { _id: req.params.id, userId: req.user.id },
      { model, manufacturer, insuranceExpiry, taxDate, testDate, pollutionDate },
      { new: true }
    );

    if (!vehicle) {
      return res.status(404).json({ message: 'Vehicle not found' });
    }

    res.json(vehicle);
  } catch (error) {
    res.status(400).json({ message: 'Error updating vehicle', error: error.message });
  }
});

// Delete vehicle
router.delete('/:id', auth, async (req, res) => {
  try {
    const vehicle = await Vehicle.findOneAndDelete({ _id: req.params.id, userId: req.user.id });
    
    if (!vehicle) {
      return res.status(404).json({ message: 'Vehicle not found' });
    }

    res.json({ message: 'Vehicle deleted successfully' });
  } catch (error) {
    res.status(400).json({ message: 'Error deleting vehicle', error: error.message });
  }
});

module.exports = router;