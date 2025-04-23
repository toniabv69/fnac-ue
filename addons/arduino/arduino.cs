using Godot;
using System;
using System.IO.Ports;


public partial class arduino : Node
{
	[Signal]
	public delegate void DataRecievedEventHandler(string myString);
	
	[Export]
	public int BaudRate { get; set; } = 9600;
	[Export]
	public string PortName { get; set; } = "COM4";
	
	SerialPort serialPort;
	
	public override void _Ready()
	{
		serialPort = new SerialPort
		{
			PortName = PortName,
			BaudRate = BaudRate
		};
		serialPort.DtrEnable = true;
		
		if (IsDeviceConnected(serialPort))
		{
			openPort(serialPort);
		}
		else
		{
			GD.PrintErr($"No device detected on port {PortName}.");
		}
	}
	
	
	public override void _Process(double delta)
	{
		if (serialPort == null || !serialPort.IsOpen)
		{
			if (IsDeviceConnected(serialPort))
			{
				openPort(serialPort);
			}
			return;
		}
		
		try
		{
			string message = serialPort.ReadExisting();
			if (!string.IsNullOrEmpty(message))
			{
				EmitSignal(SignalName.DataRecieved, message);
			}
		}
		catch (Exception ex)
		{
			GD.PrintErr($"Error while reading from serial port: {ex.Message}");
			// Close the port to reset the state
			serialPort?.Close();
		}
	}
	
	
	public override void _ExitTree()
	{
		if (serialPort != null && serialPort.IsOpen)
		{
			serialPort.Close();
		}
		serialPort?.Dispose();
		GD.Print("Serial port closed.");
	}
	
	
	
	private void openPort(SerialPort port)
	{
		try
		{
			port.Open();
			GD.Print($"Port {port.PortName} opened successfully.");
		}
		catch (Exception ex)
		{
			GD.PrintErr($"Failed to open port {port.PortName}: {ex.Message}");
		}
	}
	
	private bool IsDeviceConnected(SerialPort port)
	{
		try
		{
			if (!port.IsOpen)
			{
				port.Open();
				port.Close();
			}
			return true;
		}
		catch
		{
			return false;
		}
	}
}
