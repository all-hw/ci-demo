# Access All-Hardware Service in Your CI Workflow

CI/CD techniques are coming to the embedded world and now [All-Hardware](https://all-hw.com/) service is enabling the remote access to the newest [Ensemble E7](https://www.alifsemi.com/products/) development board as well as others types of popular development [boards](https://all-hw.com/app/index.html#/hardware).

The Ensemble™ processor family is built on the latest generation embedded processing technology that scales from single Arm® Cortex®-M55 microcontrollers (MCUs) to a new class of multi-core devices — fusion processors — that blend up to two Cortex-M55 MCU cores, up to two Cortex-A32 microprocessors (MPU) cores capable of running high-level  operating systems, and up to two Arm Ethos™-U55 microNPUs for AI/ML acceleration.


This demo is intended to show how to speed-up the process of the embedded firmware development by automation of the firmware testing on the cloud hardware.

Here we'll run a simple echo application on the single Cortex-M55 core of Ensemble DevKit-E7 development board using the GitHub Actions and by using REST requests wrapped with the shell scripts. Using this guide you can also run your firmware on any other supported [board](https://all-hw.com/app/index.html#/hardware).


> For this moment the demo is using precompiled examples. To get the source code of the examples please contact [AlifSemiconductor](https://www.alifsemi.com/). Once the source code will be available for the public the demo will be updated with detailed instruction of getting the code and building the project.

## Getting the CI Access

Please visit the All-Hardware's [board selector page](https://all-hw.com/app/#/hardware) and choose Ensemble DevKit board, then press "Get CI/CD access" button.

![board selection](https://github.com/all-hw/ci-demo/raw/main/docs/book_the_board.png)

You will get an API key which you'll need later to access the board. For the demo we'll use the *ba1e491b-331b-4e35-b799-f714b8505843*.

## Quick Look at the Demo Content

The [DEMO project](https://github.com/all-hw/ci-demo.git) contains:

* UART echo example application
* TFLite microspeech example application
* scripts to upload firmware binary to the All-Hardware service
* GitHub CI workflow configuration

Ok, great! Let's flash our simple applications to the cloud hardware.

## Flash MCU with GitHub CI

With GitHub Actions you can easily build you CI workflow and [All-Hardware](https://all-hw.com/) service will let you to do it for your embeded development process!

Open [demo GitHub page](https://github.com/all-hw/ci-demo) and fork the repository:

![fork|690x313](https://github.com/all-hw/ci-demo/raw/main/docs/fork.png)

Now you have a fork of the CI demo repository on your account on GitHub. Lets try out the CI workflow:

![start_workflow|690x253](https://github.com/all-hw/ci-demo/raw/main/docs/start_workflow.png)

Congratulations! Your project was successfully built and run on the latest [AlifSemiconductor](https://www.alifsemi.com/) Ensemble DevKit-E7 development board!

![workflow_passed|624x500](https://github.com/all-hw/ci-demo/raw/main/docs/workflow_passed.png)

Now let's take a quick look at the workflow configuration file:

```yaml
name: ALL-HW ALIF CI

on:
  # Manually triggered workflow
  workflow_dispatch:
    inputs:
      binary:
        description: 'Firmware binary to flash the MCU'
        default: 'bin/HelloW.axf'
        required: true

      file:
        description: 'Input data for the task'
        default: 'test_data/uart_input.txt'
        required: true
      api_key:
        description: 'API key for the board on all-hw.com service'
        default: 'ba1e491b-331b-4e35-b799-f714b8505843'
        required: true
      timeout:
        description: 'Firmware task timeout before abort'
        default: '10'
        required: true

jobs:
  build_and_run:
    runs-on: ubuntu-20.04
    steps:
    # checking out our repository
    - name: Check out repository
      uses: actions/checkout@v2
      with:
        submodules: recursive

    # using the parameters provided above we call
    # All-Hardware GitHub actions
    # to upload your firmware to the cloud hardware
    - name: Run firmware upload to All-Hardware
      id: task
      uses: all-hw/uart-task@main
      with:
        binary: ./${{ github.event.inputs.binary }}
        uart-in: ./${{ github.event.inputs.file }}
        api-key: ${{ github.event.inputs.api_key }}
        timeout: ${{ github.event.inputs.timeout }}
      timeout-minutes: 1

    - name: Getting the Status
      run: echo "${{ steps.task.outputs.status }}"

    - name: Getting the UART output
      run: echo "${{ steps.task.outputs.uart-out }}"

    - name: Getting the execution result code
      run: echo "${{ steps.task.outputs.result-code }}"
```

Firmware upload done by [All-Hardware GitHub Actions](https://github.com/all-hw/uart-task) and you can easily integrate it into your own CI workflow.

## Flash MCU with REST API

We've wrapped the API requests with shell scripts for this examples. Check out the [REST API description](#REST-API-description).

_Requirements: git, curl, jq_

Clone the demo from Github repository:
```bash
git clone https://github.com/all-hw/ci-demo.git
```

Modify _$API_KEY_ variable in the file scripts/ci_sampe.sh_ to the API key you've got during booking the board.

### Echo Application

Run following command to upload the Echo example to the All-Hardware remote board:

```bash
./scripts/ci_sample.sh task bin/HelloW.axf test_data/uart_input.txt
```

We are flashing the firmware binary from *bin/HelloW.axf* file and passing content of the _test_data/uart_input.txt_ file to the microcontroller's uart input. Here is the expected output:

`7b00ab0c-8566-46ae-ada8-45bc2bdc81d4`

It is a task UUID, you can use it to get the status of the operation:

```bash
./scripts/ci_sample.sh status 7b00ab0c-8566-46ae-ada8-45bc2bdc81d4
```

The result should be following:
```text
Status: finished
Exit code: 156
UART output:

-- Remote service test application - echo test --
test1...
test2...
test3...
Hello World!!!
```


### Microspeech Application

Microspeech source code available on the [Alif's GitHub page](https://github.com/arashed-alif/VHT-TFLmicrospeech). You can get the source code using following commands:

```text
git clone https://github.com/arashed-alif/VHT-TFLmicrospeech
cd VHT-TFLmicrospeech
git checkout Platform_Alif_Ensemble
```

Follow the instructions [here](https://github.com/arashed-alif/VHT-TFLmicrospeech/tree/Platform_Alif_Ensemble/Platform_Alif_Ensemble) to build the example.

We already built the example so you can just run it on remote hardware. Make sure you've set API_KEY variable as described into previous example, then run following command:

```bash
./scripts/ci_sample.sh task bin/microspeech.axf test_data/empty.txt
```

Then request the status of the operation:
```bash
./scripts/ci_sample.sh status b2dc9f02-5829-11ec-bf2c-67fc59cf5b2a
```

And the expected output is following:

```text
Executing bin/microspeech.axf on https://cloud.all-hw.com/ci with timeout 10s
Waiting for result... 8a668658-a764-4a15-b71f-afb6c8bdaece
Result code: 156
UART output: =================VVVVVVVVVVVVV=================================
UART is enabled.
Heard silence (153) @400ms
Heard yes (158) @1200ms
Heard unknown (141) @5100ms
Heard no (141) @6100ms
..... more lines here ......

==============================^^^^^^^^^^^^^=================================
```


## REST API Description

### Flashing the Firmware

To flash the device you'll need to POST to `https://cloud.all-hw.com/ci/usertask?version=V3&rate=115200&log=0&timeout=10&key=<your_api_key>` following JSON:
```json
{
  "firmware": "......", <-- your firmware here
  "input": "........" <-- input data to send to UART
}
```

As a response you'll get the uuid of the created task.


### Getting the Operation Status

GET https://cloud.all-hw.com/ci/usertask?id=<task_id>

The response to the task status request has JSON type, which fields are described in the table below.

|Field name|Type|Comment|
| --- | --- | --- |
|status| String|queued – the task is registered on the CI server, but has not been started yet for some reason (for example, there are no free boards); running – the task script started on the terminal, but has not finished yet; finished – the task has terminated on the terminal, or an error has occurred that does not allow the script to run on the terminal|
|created|Date/time| the time when the task was registered on the CI server|
|started|Date/time|the time when the task started on the terminal, or an error preventing it from running has been found|
|finished|Date/time|the time when the task completed its work on the terminal, or an error preventing it from running has been found|
|code|Int|the return code of the task; null if the status is not finished. 255 if the task could not be started normally on the terminal|
|output|String|the current output of the task. It can be null if the status is not finished. The final output of the task if the status is finished|
|reservation|Int|the reservation ID on the All-HW server. It can be useful for diagnosing some problems with the task. For example, you can use it to find out which specific board from the group was booked to complete the task|
